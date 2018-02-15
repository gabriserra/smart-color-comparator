%% Pattern network with colors

function best_n = mlp_pat_net(input, targets)

    % Load data
    x = input';
    t = targets';

    % Wait bar
    h = waitbar(0,'NN Training (0 %)','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(h,'canceling',0);

    % Choose a Training Function
    % For a list of all training functions type: help nntrain
    % 'trainlm' is usually fastest.
    % 'trainbr' takes longer but may be better for challenging problems.
    % 'trainscg' uses less memory. Suitable in low memory situations.

    trainFcn = 'trainscg';

    % Choose the number of hidden neurons
    h_num_min = 1;
    h_num_max = 200;
    step = 10;
    num = 20;

    % Prepare plot environment
    title('Smart color comparator');
    xlabel('Hidden neurons numbers');
    ylabel('Average MSE & R');
    hold on;

    % Allocating averages vector & network result
    averageMSEVector = zeros(1, num);
    averageRVector = zeros(1, num);
    netResult = zeros(size(t,1), size(t,2), num);

    % Init the loop count
    j = 1;

    % For each number of hidden layer
    for hiddenLayerSize = h_num_min:step:h_num_max

        % Create the network
        net = patternnet(hiddenLayerSize, trainFcn);

        % Disabling both prints on command line and window
        net.trainParam.showWindow = false;
        net.trainParam.showCommandLine = false;

        % Setup Division of Data for Training, Validation, Testing
        net.divideFcn = 'divideint';
        % net.divideParam.trainRatio = 70/100;
        % net.divideParam.valRatio = 15/100;
        % net.divideParam.testRatio = 15/100;

        % Init the average MSE and R values
        averageMSE = 0;
        averageR = 0;

        % Train the Network 10 times and test the network
        for i = 1:10
            [net, tr] = train(net, x, t);

            % Test the Network
            y = net(x);

            % Calculate error history
            % e = gsubtract(t,y);

            % Calculate MSE (performance) and accuracy value
            performance = perform(net, t, y);
            R = mean(regression(t, y));
            
            % Update average sums
            averageMSE = averageMSE + performance;
            averageR = averageR + R;
        end

        % Update the waitbar
        percent = j/((h_num_max - h_num_min + step)/step);
        waitbar(percent,h,strcat('NN Training (',num2str(floor(percent*100)),' %)'));

        if getappdata(h,'canceling')
            delete(h);
            return;
        end

        % Calculate averages
        averageMSE = averageMSE / 10;
        averageR = averageR / 10;

        % View the Network
        % view(net);

        % Update average vectors
        averageMSEVector(j) = averageMSE;
        averageRVector(j) = averageR;

        % Save network result
        netResult(:, :, j) = y;

        % Plots
        %figure, plotperform(tr)
        %figure, plottrainstate(tr)
        %figure, ploterrhist(e)
        %figure, plotconfusion(t,y)
        %figure, plotroc(t,y)

        % Update loop count
        j = j + 1;
    end

    % Delete waitbar
    delete(h);

    % Plots the average performance and the average R value
    plot(h_num_min:step:h_num_max, averageMSEVector, 'r');
    plot(h_num_min:step:h_num_max, averageRVector, 'b');
    
    % Add the legend to the plot
    legend('Average MSE', 'Average R');

    % Plot best network confusion matrix
    [~, best_n] = min(averageMSEVector);
    figure, plotconfusion(t, netResult(:, :, best_n));
    figure, plotregression(t, netResult(:, :, best_n));

end