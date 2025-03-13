% Author: Kimi (GenAI)
% Modify
%       2025.03.10, add Doppler measurement --sbs 
% Input: 
%
%

function [xyzdtRat] = leastSquareVel(xyzdt, satPositions, satVelocity, obs, settings)
    % leastSquareVel 使用最小二乘法计算单点测速
    % 输入:
    %   xyzdt - 接收机位置和时间 [x, y, z, t]
    %   satPositions - 卫星位置矩阵，每行是一个卫星的位置 [x, y, z]
    %   satVelocity - 卫星速度矩阵，每行是一个卫星的速度 [vx, vy, vz]
    %   settings - 设置结构体，包含必要的参数
    % 输出:
    %   xyzdtRat - 速度估计结果结构体，包含速度分量和统计信息

    % 初始化输出结构体
    % xyzdtRat = struct('velocity', zeros(4, 1), 'residuals', [], 'covariance', [], 'status', 'Success');
    xyzdtRat = zeros(4,1);

    % 提取接收机位置和时间
    recPosition = xyzdt(1:3);
    recTime = xyzdt(4);

    % 卫星数量
    numSats = size(satPositions, 2);

    % 构建设计矩阵 H 和观测向量 y
    H = zeros(numSats, 4);
    y = zeros(numSats, 1);

    for i = 1:numSats
        % 卫星位置和速度
        satPos = satPositions(:, i)';
        satVel = satVelocity(:, i)';

        % 计算接收机到卫星的单位向量
        rangeVec = satPos - recPosition;
        range = norm(rangeVec);
        unitRangeVec = rangeVec / range;

        % 设计矩阵 H 的行
        H(i, 1:3) = -unitRangeVec;
        H(i, 4) = 1;

        % 观测值：卫星速度在视线方向的投影
        y(i) = obs(i) - satVel * unitRangeVec';
    end

    % 最小二乘解
    % 加权最小二乘（假设权重矩阵为单位矩阵）
    % 如果有观测噪声协方差矩阵，可以在这里设置权重
    if isfield(settings, 'weightMatrix')
        W = settings.weightMatrix;
    else
        W = eye(numSats);
    end

    % 法方程矩阵
    HTWH = H' * W * H;

    % 检查矩阵是否可逆
    if det(HTWH) < 1e-12
        % xyzdtRat.status = 'Singular Matrix';
        % xyzdtRat.velocity = NaN(4, 1);
        % xyzdtRat.residuals = NaN(numSats, 1);
        % xyzdtRat.covariance = NaN(4, 4);
        return;
    end

    % 计算速度估计值
    xyzdtRat = HTWH \ (H' * W * y);

    % % 计算残差
    % xyzdtRat.residuals = y - H * xyzdtRat.velocity;
    % 
    % % 计算协方差矩阵
    % xyzdtRat.covariance = inv(HTWH);

    % 如果需要，可以在这里添加更多的后处理步骤
    % 例如，检查解的合理性、计算标准差等
end