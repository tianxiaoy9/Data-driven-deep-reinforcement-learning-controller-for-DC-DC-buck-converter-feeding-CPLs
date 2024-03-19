function [output] = relu(x)
% 激活函数 RELU 
    output = (x > 0).* x;
end
