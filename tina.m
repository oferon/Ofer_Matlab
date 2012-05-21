
function tinaFn = tina(directory, mode, tablename, username, password)
%javaaddpath('C:\Users\Elena\Documents\MATLAB\mysql-connector-java-5.1.18\mysql-connector-java-5.1.18-bin.jar')

 %directory = 'c:\tina_videos\'; mode = 'setup';
 allFiles  = dir(directory);
 fileNum = length(allFiles);
 %aviFilename = strcat(directory, allFiles(3).name);
 aviFilename = strcat(directory, allFiles(3).name);
 resizingIndex = 0.25;
 tinaObj=VideoReader(aviFilename);    %imports video as object from file
 %nframes=get(tinaObj,'NumberOfFrames'); 
 backgroundOrig = imread('tina_background.tif');
 %background = bitand(backgroundOrig, resolution);
 background = imresize(backgroundOrig, resizingIndex);
 IOrig=read(tinaObj,25); 
 I = imresize(IOrig, resizingIndex);
 figure, imagesc(I);
 hFH = imfreehand(); 
 % Create a binary image ("mask") from the ROI object.
 binaryImage = hFH.createMask();
 fid=fopen('centable.txt','W');   %opens text file with name, writes data to be saved to existing text file
 blobMin = 5;
 colorMax = -50;
 filterSize = 3;
 displayFrequency = 5;
 %fprintf(fid, 'Frame#\t x\t y\t MajorAxisLength\t MinorAxisLength\t theta\n'); 
 gaussianFilter = fspecial('average', filterSize);
 gaussianBackground = imfilter(background, gaussianFilter, 'symmetric', 'conv');
 % JDBC parameters
%  host = 'localhost';
%  dbName='matlab';
%  jdbcString = sprintf('jdbc:mysql://%s/%s', host, dbName);
%  jdbcDriver = 'com.mysql.jdbc.Driver';
 %conn = database(dbName,'root','elena', jdbcDriver, jdbcString); 
 
 
 
 if (strcmp(mode,'setup'))
    uicontrol('Style','text','Position',[10 50 200 20],'String','Remove blobs smaller than x pixels');
    uicontrol('Style','text','Position',[25 10 170 20],'String','0...............100...............200');   
    uicontrol('Style','text','Position',[250 50 200 20],'String','Threshold');
    uicontrol('Style','text','Position',[265 10 170 20],'String','-100..............0...............100');   
    uicontrol('Style','text','Position',[500 50 200 20],'String','Filter size');
    uicontrol('Style','text','Position',[515 10 170 20],'String','1......2......3......4......5......6');
    uicontrol('Style','text','Position',[10 700 50 20],'String','Frame:');        
 end
 
 timestamp = datestr(now, 'yyyy-mm-dd HH:MM:SS');
 mysql('open', 'localhost',username, password); 
 mysql('create schema if not exists matlab');
 mysql('use matlab');
  
 mysql('create table if not exists matlab.batch (batch_id int not null AUTO_INCREMENT, processed_date datetime not null, table_name varchar(64) not null, blobMin int not null, colorMax int not null, filterSize int not null, PRIMARY KEY (batch_id) )');
 sqlString = strcat('insert into matlab.batch (processed_date, table_name, blobMin, colorMax, filterSize) values("', ...
     timestamp, '", "', tablename, '", ', num2str(blobMin), ', ', num2str(colorMax), ', ', num2str(filterSize), ')' );
 mysql(sqlString);
  
 mysql('create table if not exists matlab.file (file_id int not null AUTO_INCREMENT, file_name varchar(64) not null, file_start datetime not null, num_frames int not null, PRIMARY KEY (file_id) )');
  
  
 sqlString = strcat('create table if not exists matlab.',tablename,...
      '(frame int not null,x numeric(6,2) not null,y numeric(6,2) not null,major_axis numeric(6,2),minor_axis numeric(6,2), theta numeric(6,2), file_id int)');
 mysql(sqlString);
 mysql('close');
 for k = 3:fileNum
  tic
  
  aviFilename = strcat(directory, allFiles(k).name);
  mysql('open', 'localhost',username, password); 
  mysql('use matlab');
  
%   [token, remain] = strtok(allFiles(k).name, '_');
%   [token2, remain2] = strtok(remain, '_');
%   [token3, remain3] = strtok(remain2, '.');
%   [token4, remain4] = strtok(remain3, '.');
%   seconds = token4;
%   if (strcmp(token4, '00') == 0)
%       seconds = num2str(str2num(token4)*25);
%   end
%   tempStartTime = strcat(token2, strrep(token3, '_', ''), seconds);
%  
%   startTime = datestr(datenum(tempStartTime, 'yymmddHHMMSS'), 'yyyy-mm-dd HH:MM:SS');
  
  %clearvars -except fid directory allFiles fileNum resizingIndex hFH binaryImage blobMin colorMax filterSize displayFrequency k gaussianFilter gaussianBackground;
 
  %fprintf(fid, '%s\t%s\n', aviFilename, timestamp);
  if (strcmp(mode,'setup'))
    uicontrol('Style','text','Position',[10 680 325 20],'String', strcat('Filename:', aviFilename));
    blobHandle = uicontrol('Style', 'slider', 'Min',0,'Max',200,'SliderStep',[0.01 0.10], 'Position', [10 30 200 20], 'Value', blobMin);
    thresholdHandle = uicontrol('Style', 'slider', 'Min',-100,'Max',100,'SliderStep',[0.005 0.05], 'Position', [250 30 200 20], 'Value', colorMax);
    filterHandle = uicontrol('Style', 'slider', 'Min',1,'Max',6,'SliderStep',[0.2 0.2], 'Position', [500 30 200 20], 'Value', filterSize);
    
    %uicontrol('Style', 'pushbutton', 'String', 'Pause','Position', [32 250 50 20],'Callback', 'pause'); % Pushbutton string callback   
    uicontrol('Style', 'pushbutton', 'String', 'Pause','Position', [32 250 50 20],'Callback', 'uiwait'); % Pushbutton string callback   
    uicontrol('Style', 'pushbutton', 'String', 'Resume','Position', [32 225 50 20],'Callback', 'uiresume');
    %blobHandle = uicontrol('Style', 'slider', 'Min',0,'Max',200,'Value',blobMin,'SliderStep',[0.01 0.10], 'Position', [10 30 200 20],'Callback', ['blobMin=get(blobHandle,''Value'');']);
    %thresholdHandle = uicontrol('Style', 'slider', 'Min',-100,'Max',100,'Value',colorMax,'SliderStep',[0.005 0.05], 'Position', [250 30 200 20],'Callback', ['colorMax=get(threshold,''Value'');']);
    %filterHandle = uicontrol('Style', 'slider', 'Min',1,'Max',6,'Value',filterSize,'SliderStep',[0.2 0.2], 'Position', [500 30 200 20], 'Callback', ...
    %  ['filterSize=get(filter,''Value'');gaussianFilter=fspecial(''average'', filterSize);gaussianBackground=imfilter(background, gaussianFilter, ''symmetric'', ''conv'');']);       
  end
  
  
  tinaObj=VideoReader(aviFilename);    %imports video as object from file
  allFrames=read(tinaObj);
  nframes=get(tinaObj,'NumberOfFrames');
  startTime = datestr(datenum(allFiles(k).date), 'yyyy-mm-dd HH:MM:SS');
  
  sqlString = strcat('insert into matlab.file (file_name, file_start, num_frames) values(''',strrep(aviFilename, '\', '\\'), ''', ''', startTime, ''', ', num2str(nframes), ')' );

  mysql(sqlString);
  fileId = mysql('select max(file_id) from matlab.file');
  %mySize = size(allFrames, 4);
  for j=1:nframes %nframes:mySize
    %singleFrame1Orig=read(tinaObj, j); 
    singleFrame1Orig=allFrames(:,:,:,j);
    singleFrame1 = imresize(singleFrame1Orig, resizingIndex);
    burnedImage = singleFrame1;
    burnedImage(binaryImage) = 0;
    singleFrame = rgb2gray(singleFrame1);
    gaussianImage = imfilter(singleFrame, gaussianFilter, 'symmetric', 'conv');
    %Subtract background
    Idouble=double(gaussianImage)-double(gaussianBackground);
    I2 = Idouble < colorMax;
    I2(~binaryImage) = 0;
    %Remove small structures; blur image, structuring element, and dilate
    I25 = bwareaopen(I2,blobMin);  %removes blobs with less than the specified pixels
    se=strel('square',8);   %using disk took 60 sec, versus square which took 40 on average, for 1671 frames
    I3=imdilate(I25,se);
    %I33=bwlabel(I3, 4);
    s=regionprops(I3,'Centroid', 'Orientation', 'MajorAxisLength', 'MinorAxisLength');
    centroids=cat(1, s.Centroid);
    for n=1:numel(s)
          x=s(n).Centroid(1);
          y=s(n).Centroid(2);
          majorAxis = s(n).MajorAxisLength;
          minorAxis = s(n).MinorAxisLength;
          theta = s(n).Orientation;
          fprintf(fid, '%d\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %6.2f\t %d\n',j, x, y, majorAxis, minorAxis, theta, fileId);     
    end    
    if (strcmp(mode,'setup') && mod(j,displayFrequency) == 0)
         
        if (isappdata(blobHandle, 'blobMin') == 1)
            blobMin = getappdata(blobHandle, 'blobMin');
        end
        setappdata(blobHandle, 'blobMin', blobMin);
        set(blobHandle, 'callback', @setBlob, 'Value', blobMin); 
        
        
        if (isappdata(thresholdHandle, 'colorMax') == 1)
            colorMax = getappdata(thresholdHandle, 'colorMax');
        end
        setappdata(thresholdHandle, 'colorMax', colorMax);
        set(thresholdHandle, 'callback', @setThreshold, 'Value', colorMax);       
%['filterSize=get(filter,''Value'');gaussianFilter=fspecial(''average'', filterSize);gaussianBackground=imfilter(background, gaussianFilter, ''symmetric'', ''conv'');'])
        if (isappdata(filterHandle, 'filterSize') == 1)
            filterSize = getappdata(filterHandle, 'filterSize');
            gaussianFilter = getappdata(filterHandle, 'gaussianFilter');
            gaussianBackground = getappdata(filterHandle, 'gaussianBackground');
        end
        setappdata(filterHandle, 'filterSize', filterSize);
        setappdata(filterHandle, 'gaussianFilter', gaussianFilter);
        setappdata(filterHandle, 'gaussianBackground', gaussianBackground);
        set(filterHandle, 'callback', {@setFilter, background}, 'Value', filterSize); 
    
        uicontrol('Style','text','Position',[60 700 30 20],'String',num2str(j));
        subplot(2,2,1),imshow(burnedImage);
        subplot(2,2,2),imagesc(I2);  
        subplot(2,2,3),imagesc(Idouble);
        subplot(2,2,4),imshow(I3);
        hold on
        if (size(centroids) > [0 0])
           plot(centroids(:,1), centroids(:,2), 'r*');  %x-coords (:,1), y (:,2)
        end
        hold off
        pause(0.0001);  
    end  
  end
  fclose(fid);

  
  
  
  sqlString = strcat('load data infile ''C:\\Users\\Elena\\Documents\\MATLAB\\centable.txt'' into table matlab.',tablename);
  mysql(sqlString);
  
  %commit(conn);
  save('tina_save.mat', 'directory', 'allFiles', 'fileNum', 'resizingIndex', 'hFH', 'binaryImage', 'displayFrequency', 'gaussianFilter', ...
      'gaussianBackground', 'background', 'mode', 'blobMin', 'colorMax', 'filterSize', 'k', 'username', 'password', 'tablename');
  mysql('close');
  clear all;
  load tina_save.mat;
  fid=fopen('centable.txt','W');
  toc
 end
 
 fclose(fid);
 %close(conn);
end

function setBlob(hObject, eventdata)
myhandle = gcbo;
blobMin = get(hObject, 'Value');
setappdata(myhandle,'blobMin',blobMin);
end

function setThreshold(hObject, eventdata)
myhandle = gcbo;
colorMax = get(hObject, 'Value');
setappdata(myhandle,'colorMax',colorMax);
end

function setFilter(hObject, eventdata, background)
myhandle = gcbo;
filterSize = get(hObject, 'Value');
setappdata(myhandle,'filterSize',filterSize);
gaussianFilter=fspecial('average', filterSize);
setappdata(myhandle, 'gaussianFilter', gaussianFilter);
gaussianBackground=imfilter(background, gaussianFilter, 'symmetric', 'conv');
end

