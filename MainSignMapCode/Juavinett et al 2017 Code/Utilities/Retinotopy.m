function Retinotopy(saveFigsTag, varargin)
%Runs kalatsky retinotopy analysis and saves the figures and data if
%saveFigsTag is set to 1.  If no additional inputs are specified, the
%function will pull the expt anim maskS and bw from the currently loaded
%experiment in pF0.  Additional inputs include: anim, expt, baseExpt and
%transformed image file lcoation.  If the baseExpt is not specified, the
%function will run the kalatsky retinotopy on the experiment designated by
%anim and expt.  This requires that the file
%RootDir:\anim\pF0_vars\anim_expt_pF0_vars.mat exists.  This file is
%generated from the pF0_addon GUI, which saves the cellS, maskS and bw
%variables in this file.  If a baseExpt is specified in the fourth input to
%Retinotopy, then the function will load the maskS and bw from that
%experiment and use that cell mask for analysis.  This experiment must be
%from the same animal, and it is presumed that a transformed image exists
%generated from the PrePopAnalysis GUI.  The name and location of this
%transformed image file must be included in the fifth input to the
%retinotopy function.  If the transformed image mode is used, all files
%generated by Retinotopy will bear the name of the two experiments used in
%the registration with the base experiment named second.
%
%edited by JHM 10-29-10
%written by MEG, IN and JHM

clear AnalDir RootDir
if isempty(varargin)  %use current pF0 variables
    global anim maskS expt bw
elseif size(varargin,2) == 2  %use input arguments for experiment variables
    anim = char(varargin(1));
    expt = char(varargin(2));
    pF0filenm = strcat('/Users/marinagarrett/MapCortex/AnalyzedData-Pop/IndividualExperiments/',anim,'/','pF0_vars/',anim,'_',expt,'_pF0_vars.mat')
    load(pF0filenm)
    %maskS = pF0file.maskS;
    %bw = pF0file.bw;
    %clear pF0file
    trxFlag = 0;
elseif size(varargin,2) >2  %use imgtrx
    anim = char(varargin(1));
    expt = char(varargin(2));
    baseExpt = char(varargin(3));  %base experiment used to image register map and to use maskS
    pF0file = strcat('/Users/marinagarrett/MapCortex/AnalyzedData-Pop/IndividualExperiments/',anim,'/','pF0_vars/',anim,'_',baseExpt,'_pF0_vars.mat');  %use variables from baseExpt
    load(pF0file)
    %maskS = pF0file.maskS;
    %bw = pF0file.bw;
    %clear pF0file
    trxImgFile = varargin(4); %full filename for transformed map
    outputString = [anim,'_',expt,'_trx_',baseExpt] %suffix for retinotopy output files
    trxFlag = 1;
end

ExptID = char(strcat(anim,'_',expt))

qstring='Is this a Horizontal or Vertical Retinotopy experiment?';
title='Retinotopy?';
button = questdlg(qstring,title,'Horizontal','Vertical','Cancel','Cancel');
if strcmp(button,'Horizontal') == 1
    Horiz=1;
    Vert=0;
elseif strcmp(button,'Vertical') == 1
    Vert=1;
    Horiz=0;
end

if Horiz == 1

    % if doing this analysis on a transformed, registered image, select the .mat file for the kmap_hor variable
    %in order to determine eccentricity values of cells in registered image
%    [filename path filterindex]=uigetfile({'*.mat';'*.tif',}, 'Get Transformed Image');

%    if filterindex ==0
    if trxFlag == 0
        saveret=1;
        savetransret=0;

        f1 = f1meanimage;  %Build F1 images (takes the longest)
        L = fspecial('gaussian',15,1);  %make spatial filter
        bw = ones(size(f1{1}));
        % [kmap_hor kmap_vert] = processkret(f1,maskS.bwCell{1},L);  %Make maps to plot, delete L if no smoothing
        [kmap_hor kmap_vert] = processkret(f1,bw,L);  %Make maps to plot, delete L if no smoothing

        xsize = getparam('x_size');
        horscfactor = xsize/360;
        kmap_hor = kmap_hor*horscfactor;

    elseif trxFlag == 1
        %a=strcat(path,filename);
        load(char(trxImgFile));
        kmap_hor=imgtrx.img_out;
        savetransret=1;
        saveret=0;
        xsize = getparam('x_size');
    end

    cellmask = maskS.bwCell{1};  %Cell mask within this ROI
    masklabel = bwlabel(cellmask);
    celldom = unique(masklabel);
    Ncell = length(celldom);
    Nneuron = 0;

    for p = 2:Ncell
        [idcelly idcellx] = find(masklabel == celldom(p));
        Nneuron = Nneuron+1;
        %     xvalues{Nneuron}=idcellx;
        %     yvalues{Nneuron}=idcelly;
        pos{Nneuron}=[idcelly idcellx];
    end
  

    for s = 1:Nneuron
        for q=1:size(pos{s},1)
            eccval(q)=kmap_hor((pos{s}(q,1)),(pos{s}(q,2)));
        end
        Horiz_Eccentricity(s)=mean(eccval(q));
    end

    HorizRet=figure('Name','Horizontal Retinotopy','NumberTitle','off');
    imagesc(kmap_hor,[-xsize/2 xsize/2])
    %     title_name = strcat(ExptID,' Horizontal Retinotopy');
    %     title(title_name,'fontweight','b','FontSize',16,'Interpreter','none');
    colorbar('SouthOutside')
    set(gcf,'Color','w')
    colormap hsv
    truesize

    HorizEccentricity=figure('Name','Horizontal Retinotopy Histogram','NumberTitle','off');
    hist(Horiz_Eccentricity,10)
    %     title('Horizontal Retinotopy Histogram')
    set(gcf,'Color','w')
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',[1 1 0],'EdgeColor','black');
    xlabel('Eccentricity (degrees)'),ylabel('# cells')
    xlim([-80,80])

    %Save plots and variables
    if (saveFigsTag == 1) && (saveret ==1)
        clear AnalDir RootDir
        RootDir='/Users/marinagarrett/MapCortex/AnalyzedData-Pop/IndividualExperiments/';
        AnalDir=strcat(anim,'/',ExptID,'_HorizRet','/');
        AnalDir=char(strcat(RootDir,AnalDir))
        if exist(AnalDir) == 0
            mkdir(AnalDir)
            ContinueTag = 1;
        elseif exist(AnalDir) == 7
            button = questdlg('Warning: The PopAnalysis directory already exists for this experiment.  Hit Cancel to stop the save function.','Overwrite data?','Overwrite','Cancel','Cancel');
            if strcmp(button,'Overwrite') == 1
                ContinueTag = 1;
            elseif strcmp(button,'Cancel') == 1
                ContinueTag = 1;
                error('Save operation canceled by user. Consider renaming existing PopAnalysis directories and redoing the analysis.');
            end
        end
        if ContinueTag == 1
            saveas(HorizRet,char(strcat(AnalDir,ExptID,'_HorizRet.fig')))
            saveas(HorizRet,char(strcat(AnalDir,ExptID,'_HorizRet.tif')))
            saveas(HorizRet,char(strcat(AnalDir,ExptID,'_HorizRet.eps')))
            saveas(HorizEccentricity,char(strcat(AnalDir,ExptID,'_HorizEccentricityHist.fig')))
            saveas(HorizEccentricity,char(strcat(AnalDir,ExptID,'_HorizEccentricityHist.tif')))
            saveas(HorizEccentricity,char(strcat(AnalDir,ExptID,'_HorizEccentricityHist.eps')))
            filename=char([AnalDir,ExptID,'_HorizRetAnalysis.mat']);
            save(filename,'masklabel','celldom','Ncell','pos','Horiz_Eccentricity','ExptID','kmap_hor','xsize');
            filename2=char([AnalDir,ExptID,'_kmap_hor.mat']);
            save(filename2,'kmap_hor');
        end
    end

    %Save plots and variables for transformed experiment
    if (saveFigsTag == 1) && (savetransret == 1)
        clear AnalDir RootDir
        RootDir='/Users/marinagarrett/MapCortex/AnalyzedData-Pop/IndividualExperiments/';
        AnalDir=strcat(anim,'/',ExptID,'_HorizRet','/');
        AnalDir=char(strcat(RootDir,AnalDir));
        if exist(AnalDir) == 0
            mkdir(AnalDir)
            ContinueTag = 1;
        elseif exist(AnalDir) == 7
            button = questdlg('Warning: The PopAnalysis directory already exists for this transformed experiment.  Hit Cancel to stop the save function.','Overwrite data?','Overwrite','Cancel','Cancel');
            if strcmp(button,'Overwrite') == 1
                ContinueTag = 1;
            elseif strcmp(button,'Cancel') == 1
                ContinueTag = 1;
                error('Save operation canceled by user. Consider renaming existing PopAnalysis directories and redoing the analysis.');
            end
        end
        if ContinueTag == 1
            saveas(HorizRet,char(strcat(AnalDir,ExptID,'_HorizRet_',outputString,'_Trans.fig')))
            saveas(HorizRet,char(strcat(AnalDir,ExptID,'_HorizRet_',outputString,'_Trans.tif')))
            saveas(HorizRet,char(strcat(AnalDir,ExptID,'_HorizRet_',outputString,'_Trans.eps')))
            saveas(HorizEccentricity,char(strcat(AnalDir,ExptID,'_HorizEccentricityHist_',outputString,'_Trans.fig')))
            saveas(HorizEccentricity,char(strcat(AnalDir,ExptID,'_HorizEccentricityHist_',outputString,'_Trans.tif')))
            saveas(HorizEccentricity,char(strcat(AnalDir,ExptID,'_HorizEccentricityHist_',outputString,'_Trans.eps')))
            filename=char([AnalDir,ExptID,'_HorizRetAnalysis_',outputString,'_Trans.mat']);
            save(filename,'masklabel','celldom','Ncell','pos','Horiz_Eccentricity','ExptID','kmap_hor','xsize');
            filename2=char([AnalDir,ExptID,'_kmap_hor_',outputString,'_trans.mat']);
            save(filename2,'kmap_hor');
        end
    end
end


% Altitude Ret analysis
if Vert ==1
    % if doing this analysis on a transformed, registered image, select the .mat file for the kmap_hor variable
    %in order to determine eccentricity values of cells in registered image
%    [filename path filterindex]=uigetfile('*.mat','*.tif', 'Get Transformed Image');

    if trxFlag == 0
        saveret=1;
        savetransret=0;


        f1 = f1meanimage;  %Build F1 images (takes the longest)
        L = fspecial('gaussian',15,1);  %make spatial filter
        bw = ones(size(f1{1}));
        % [kmap_hor kmap_vert] = processkret(f1,maskS.bwCell{1},L);  %Make maps to plot, delete L if no smoothing
        [kmap_hor kmap_vert] = processkret(f1,bw,L);  %Make maps to plot, delete L if no smoothing

        ysize = getparam('y_size');
        vertscfactor = ysize/360;
        kmap_vert = kmap_vert*vertscfactor;

    elseif trxFlag == 1
        % if performing this analysis on a registered map,
        %a=strcat(path,filename);
        load(char(trxImgFile));
        kmap_vert=imgtrx.img_out;
        savetransret=1;
        saveret=0;
        ysize = getparam('y_size');
    end


    cellmask = maskS.bwCell{1};  %Cell mask within this ROI
    masklabel = bwlabel(cellmask);
    celldom = unique(masklabel);
    Ncell = length(celldom);
    Nneuron = 0;

    for p = 2:Ncell
        [idcelly idcellx] = find(masklabel == celldom(p));
        Nneuron = Nneuron+1;
        %     xvalues{Nneuron}=idcellx;
        %     yvalues{Nneuron}=idcelly;
        pos{Nneuron}=[idcelly idcellx];
    end

    for s = 1:Nneuron
        for q=1:size(pos{s},1)
            eccval(q)=kmap_vert((pos{s}(q,1)),(pos{s}(q,2)));
        end
        Vert_Eccentricity(s)=mean(eccval(q));
    end

    VertRet=figure('Name','Vertical Retinotopy','NumberTitle','off');
    imagesc(kmap_vert,[-ysize/2 ysize/2])
    %     title('Vertical Retinotopy ','FontSize',16)
    colorbar
    set(gcf,'Color','w')
    colormap hsv
    truesize

    VertEccentricity=figure('Name','Vertical Retinotopy Histogram','NumberTitle','off');
    hist(Vert_Eccentricity,10)
    %     title('Vertical Retinotopy Histogram','FontSize',16)
    set(gcf,'Color','w')
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor',[1 0.5 0],'EdgeColor','black');
    xlabel('Eccentricity (degrees)'),ylabel('# cells')
    xlim([-80,80])


    %Save plots
    if (saveFigsTag == 1) && (saveret ==1)
        clear AnalDir RootDir
        RootDir=('/Users/marinagarrett/MapCortex/AnalyzedData-Pop/IndividualExperiments/');
        AnalDir=strcat(anim,'/',ExptID,'_VertRet','/');
        AnalDir=char(strcat(RootDir,AnalDir));
        if exist(AnalDir) == 0
            mkdir(AnalDir)
            ContinueTag = 1;
        elseif exist(AnalDir) == 7
            button = questdlg('Warning: The PopAnalysis directory already exists for this experiment.  Hit Cancel to stop the save function.','Overwrite data?','Overwrite','Cancel','Cancel');
            if strcmp(button,'Overwrite') == 1
                ContinueTag = 1;
            elseif strcmp(button,'Cancel') == 1
                ContinueTag = 1;
                error('Save operation canceled by user. Consider renaming existing PopAnalysis directories and redoing the analysis.');
            end
        end
        if ContinueTag == 1
            saveas(VertRet,char(strcat(AnalDir,ExptID,'_VertRet.fig')))
            saveas(VertRet,char(strcat(AnalDir,ExptID,'_VertRet.tif')))
            saveas(VertRet,char(strcat(AnalDir,ExptID,'_VertRet.eps')))
            saveas(VertEccentricity,char(strcat(AnalDir,ExptID,'_VertEccentricityHist.fig')))
            saveas(VertEccentricity,char(strcat(AnalDir,ExptID,'_VertEccentricityHist.tif')))
            saveas(VertEccentricity,char(strcat(AnalDir,ExptID,'_VertEccentricityHist.eps')))
            filename=char([AnalDir,ExptID,'_VertRetAnalysis']);
            save(filename,'masklabel','celldom','Ncell','pos','Vert_Eccentricity','ExptID','kmap_vert','ysize');
            filename2=char([AnalDir,ExptID,'_kmap_vert.mat']);
            save(filename2,'kmap_vert');
        end
    end
    if (saveFigsTag == 1) && (savetransret ==1)
        clear RootDir AnalDir
        RootDir=('/Users/marinagarrett/MapCortex/AnalyzedData-Pop/IndividualExperiments/');
        AnalDir=strcat(anim,'/',ExptID,'_VertRet','/');
        AnalDir=char(strcat(RootDir,AnalDir));
        if exist(AnalDir) == 0
            mkdir(AnalDir)
            ContinueTag = 1;
        elseif exist(AnalDir) == 7
            button = questdlg('Warning: The PopAnalysis directory already exists for this experiment.  Hit Cancel to stop the save function.','Overwrite data?','Overwrite','Cancel','Cancel');
            if strcmp(button,'Overwrite') == 1
                ContinueTag = 1;
            elseif strcmp(button,'Cancel') == 1
                ContinueTag = 1;
                error('Save operation canceled by user. Consider renaming existing PopAnalysis directories and redoing the analysis.');
            end
        end
        if ContinueTag == 1
            saveas(VertRet,char(strcat(AnalDir,ExptID,'_VertRet_',outputString,'_Trans.fig')))
            saveas(VertRet,char(strcat(AnalDir,ExptID,'_VertRet_',outputString,'_Trans.tif')))
            saveas(VertRet,char(strcat(AnalDir,ExptID,'_VertRet_',outputString,'_Trans.eps')))
            saveas(VertEccentricity,char(strcat(AnalDir,ExptID,'_VertEccentricityHist_',outputString,'_Trans.fig')))
            saveas(VertEccentricity,char(strcat(AnalDir,ExptID,'_VertEccentricityHist_',outputString,'_Trans.tif')))
            saveas(VertEccentricity,char(strcat(AnalDir,ExptID,'_VertEccentricityHist_',outputString,'_Trans.eps')))
            filename=char([AnalDir,ExptID,'_VertRetAnalysis_',outputString,'_Trans']);
            save(filename,'masklabel','celldom','Ncell','pos','Vert_Eccentricity','ExptID','kmap_vert','ysize');
            filename2=char([AnalDir,ExptID,'_kmap_vert_',outputString,'_trans.mat']);
            save(filename2,'kmap_vert');
        end
    end
end



