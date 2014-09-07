clear all

go_config;

optical_flow_folder     = fullfile(pfx_crowd_dataset, pfx_crowd_video, pfx_optical_flow);

optical_flow_file_names = dir([optical_flow_folder, '\*.mat']);

%%%%%%Create movie as well
movie_file_name = [optical_flow_folder, '\optical_flow_movie.avi'];

mov = avifile(movie_file_name, 'COMPRESSION', 'None','FPS', 15, 'QUALITY', 100);

for i = 1 : length(optical_flow_file_names)

    matMotionFileName = fullfile ( optical_flow_folder, optical_flow_file_names(i).name );

    load(matMotionFileName);

    flow(:,:,1) = nan2zeros(u);

    flow(:,:,2) = nan2zeros(v);

    optical_flow_im = flowToColor(flow);

    imagesc(optical_flow_im);

    axis image;

    mov = addframe ( mov, im2frame (optical_flow_im) );

    set(gca,'NextPlot','replacechildren');

    color_file_name = fullfile ( optical_flow_folder, sprintf('ColoredOpticalFlow%04d.jpg', i) );

    imwrite(optical_flow_im, color_file_name);

end

mov = close(mov);

