%% RBF network with colors

function best_n = rbf_network(input, targets)

    % Load data and subdivide train set and test set
    numSample = size(input, 1);
    [trainInd, valInd, testInd] = divideint(numSample / 4, 0.70, 0.15, 0.15);
    
    trainInd = trainInd';
    valInd = valInd';
    testInd = testInd';
    
    train_len = size(trainInd, 1);
    test_len = size(testInd, 1);
    valid_len = size(valInd, 1);
    
    x_train = zeros(4 * train_len, 420);
    t_train = zeros(4 * train_len, 2);
    x_test = zeros(4 * (test_len+valid_len), 420);
    t_test = zeros(4 * (test_len+valid_len), 2);
    
    for i = 1:train_len
        index = (trainInd(i) - 1) * 4 + 1;
        index_vector = ((i-1) * 4)+1;
        x_train(index_vector:index_vector+3, :) = input(index:index+3, :);
        t_train(index_vector:index_vector+3, :) = targets(index:index+3, :);
    end
    
    for i = 1:valid_len
        index = (valInd(i) - 1) * 4 + 1;
        index_vector = ((i-1) * 4)+1;
        x_test(index_vector:index_vector+3, :) = input(index:index+3, :);
        t_test(index_vector:index_vector+3, :) = targets(index:index+3, :);
    end
    
    for i = valid_len:valid_len+test_len-1
        index = (testInd(i-valid_len+1) - 1) * 4 + 1;
        index_vector = (i * 4)+1;
        x_test(index_vector:index_vector+3, :) = input(index:index+3, :);
        t_test(index_vector:index_vector+3, :) = targets(index:index+3, :);
    end
       
    x_train = x_train';
    t_train = t_train';
    x_test = x_test';
    t_test = t_test';
    
    % Wait bar
    h = waitbar(0,'NN Training (0 %)','CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
    setappdata(h,'canceling',0);

    % Calculating the spread range 
    [LB, UB] = spread_range(input);
    LB = floor(LB);
    UB = floor(UB);
    spreadStep = floor((UB - LB) / 10);
    spreadTry = floor((UB - LB + spreadStep) / spreadStep);
    
    % Allocating performances matrices
    MSEVector = zeros(1, spreadTry);
    RVector  = zeros(1, spreadTry);
    
    % Allocating net result matrices
    netResult = zeros(size(t_test, 1), size(t_test, 2), spreadTry);
    
    % Init the loop count
    j = 1;

    for spread = LB:spreadStep:UB

        % Create the network
        net = newrb(x_train, t_train, 0.05, spread, 500);

        % Test the Network
        y = net(x_test);

        % Calculate error history
        % e = gsubtract(t, y);

        % Calculate MSE (performance) and R-value regression
        RVector(j) = mean(regression(t_test, y));
        MSEVector(j) = perform(net, t_test, y);

        % Save network results
        netResult(:, :, j) = y;
        
        % Update the waitbar
        percent = j / spreadTry;
        waitbar(percent,h,strcat('NN Training (',num2str(floor(percent*100)),' %)'));

        if getappdata(h,'canceling')
            delete(h);
            return;
        end

        % Update loop count (spread)
        j = j + 1;
    end
    
    % Delete waitbar
    delete(h);

    % Prepare plot environment
    figure;
    title('RBF Colors');
    xlabel('Spread value');
    ylabel('Average R & MSE');

    % Plots the average performance and the average R value
    plot(LB:spreadStep:UB, MSEVector, 'r', LB:spreadStep:UB, RVector, 'b');
    
    % Add the legend to the plot
    legend('Average MSE', 'Average R');
    
    [~, best_n] = min(MSEVector);
    figure, plotconfusion(t_test, netResult(:, :, best_n));
    figure, plotregression(t_test, netResult(:, :, best_n));

end