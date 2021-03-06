function RetFigures

global anim expt Conditions maskS kmap_hor kmap_vert bw f1m magS

ExptID = strcat(anim,'_',expt); 

f1 = f1meanimage;  %Build F1 images (takes the longest)
L = fspecial('gaussian',15,3);  %make spatial filter
bw = ones(size(f1{1}));
[kmap_hor kmap_vert] = processkret(f1,maskS.bwCell{1},L);  %Make maps to plot, delete L if no smoothing

%% plot threshold maps
mag = magS.hor;
ang = kmap_hor;

%mag = log(mag);
% mag = medfilt2(mag,[3 3]);

h = fspecial('gaussian',size(mag),.1);
h = abs(fft2(h));
magf = ifft2(h.*fft2(mag));

mag = magf.^1;
mag = mag-min(mag(:));
mag = mag/max(mag(:));

thresh = .15;
id = find(mag(:)<thresh);
mag(id) = 0;

ang = fliplr(ang);
mag = fliplr(mag);
ang = rot90(ang);
mag = rot90(mag);
ang = rot90(ang);
mag = rot90(mag);
ang = rot90(ang);
mag = rot90(mag);

HorizRet_Thresh=figure('Name','Horizontal Retinotopy- Thresholded','NumberTitle','off');
imagesc(ang,'AlphaData',mag);
colormap hsv;
set(gcf,'Color','w');
axis ij


[C,h]=contour(ang,[-120 -100 -80 -60 -40 -20 0 20 40 60 80 100 120],'LineWidth',2);
%     contour(kmap_hor)
    clabel(C,'manual')
    title('Horizontal Retinotopy Contour  ','FontSize',16)
    set(gcf,'Color','w')
    colormap autumn
    colorbar
    axis ij

%% plot regular raw map
xsize = getparam('x_size');
horscfactor = xsize/360;
kmap_hor = kmap_hor*horscfactor;

kmap_hor = fliplr(kmap_hor);
kmap_hor = rot90(kmap_hor);
kmap_hor = rot90(kmap_hor);
kmap_hor = rot90(kmap_hor);

HorizRet=figure('Name','Horizontal Retinotopy','NumberTitle','off','OuterPosition',[200, 200, 500, 500]);
    imagesc(kmap_hor,[-xsize/2 xsize/2])
    title('Horizontal Retinotopy ','FontSize',16)
    colorbar('SouthOutside')
    set(gcf,'Color','w')
    colormap hsv
    axis image
   
    
%% plot contour maps with lowpassed data 

xsize = getparam('x_size');
horscfactor = xsize/360;
kmap_hor = kmap_hor*horscfactor;

HorizRet_Contour=figure('Name','Horizontal Retinotopy- Contour','NumberTitle','off');
    [C,h]=contour(kmap_hor,[-120 -100 -80 -60 -40 -20 0 20 40 60 80 100 120],'LineWidth',2);
%     contour(kmap_hor)
    clabel(C,'manual')
    title('Horizontal Retinotopy Contour  ','FontSize',16)
    set(gcf,'Color','w')
    colormap autumn
    colorbar
    axis ij
   
HorizRet_Contour=figure('Name','Horizontal Retinotopy- Contour','NumberTitle','off');
    contour(kmap_hor,[-120 -100 -80 -60 -40 -20 0 20 40 60 80 100 120])
    clabel(C,'manual')
    title('Horizontal Retinotopy Borders  ','FontSize',16)
    set(gcf,'Color','w')
    colormap hsv
    colorbar
    axis ij
    
%% save
    %Paths for saving data and plots
    Root_AnalDir = 'C:\Documents and Settings\LaserPeople\Desktop\Figures\';
    AnalDir = strcat(Root_AnalDir,anim,'\',ExptID,'_HorizRet','\');
    if exist(AnalDir) == 0
        mkdir(AnalDir)
        ContinueTag = 1;
    end
        saveas(HorizRet,strcat(AnalDir,ExptID,'_HorizRet.fig'))
        saveas(HorizRet,strcat(AnalDir,ExptID,'_HorizRet.tif'))
        saveas(HorizRet,strcat(AnalDir,ExptID,'_HorizRet.eps'))
        saveas(HorizRet_Contour,strcat(AnalDir,ExptID,'_HorizRet_Contour.fig'))
        saveas(HorizRet_Contour,strcat(AnalDir,ExptID,'_HorizRet_Contour.tif'))
        saveas(HorizRet_Contour,strcat(AnalDir,ExptID,'_HorizRet_Contour.eps'))
    

