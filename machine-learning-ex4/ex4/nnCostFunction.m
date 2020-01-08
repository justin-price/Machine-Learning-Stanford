function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

% feed forward terms
h1 = sigmoid([ones(m, 1) X] * Theta1');
h2 = sigmoid([ones(m, 1) h1] * Theta2');

% vectorize y
y_vec = zeros(m,num_labels);
    
for i = 1:m
    
    y_vec(i,y(i)) = 1;

    % cost summation using a single example at a time
    temp1 = - y_vec(i,:) .* log(h2(i,:));
    temp2 = (1-y_vec(i,:));
    temp3 = log(1 - h2(i,:));
    J += sum(temp1 - (temp2 .* temp3));
    
endfor

% remove bias terms from parameters
Theta1_reg = zeros(size(Theta1));
Theta1_reg(:,2:size(Theta1,2)) = Theta1(:,2:size(Theta1,2));
Theta2_reg = zeros(size(Theta2));
Theta2_reg(:,2:size(Theta2,2)) = Theta2(:,2:size(Theta2,2));

% regularization term
reg = (lambda/(2*m)) * (sum(sum(Theta1_reg.^2)) + sum(sum(Theta2_reg.^2)));

% cost calc with regularization 
J = J/m + reg;

X = [ones(m,1), X];
for i=1:m
   % Here X is including 1 column at begining
   
   % for layer-1
   a1 = X(i,:)'; % (n+1) x 1 == 401 x 1
   
   % for layer-2
   z2 = Theta1 * a1;  % hidden_layer_size x 1 == 25 x 1
   a2 = [1; sigmoid(z2)]; % (hidden_layer_size+1) x 1 == 26 x 1
 
   % for layer-3
   z3 = Theta2 * a2; % num_labels x 1 == 10 x 1    
   a3 = sigmoid(z3); % num_labels x 1 == 10 x 1    

   yVector = (1:num_labels)'==y(i); % num_labels x 1 == 10 x 1    
   
   %calculating delta values
   delta3 = a3 - yVector; % num_labels x 1 == 10 x 1    
   
   delta2 = (Theta2' * delta3) .* [1; sigmoidGradient(z2)]; % (hidden_layer_size+1) x 1 == 26 x 1
   
   delta2 = delta2(2:end); % hidden_layer_size x 1 == 25 x 1 %Removing delta2 for bias node  
   
   %delta_1 is not calculated because we do not associate error with the input  
   
   % CAPITAL delta update
   Theta1_grad = Theta1_grad + (delta2 * a1'); % 25 x 401
   Theta2_grad = Theta2_grad + (delta3 * a2'); % 10 x 26
    
end
  
Theta1_grad = (1/m) * Theta1_grad; % 25 x 401
Theta2_grad = (1/m) * Theta2_grad; % 10 x 26

%Calculating gradients for the regularization
Theta1_grad_reg_term = (lambda/m) * [zeros(size(Theta1, 1), 1) Theta1(:,2:end)]; % 25 x 401
Theta2_grad_reg_term = (lambda/m) * [zeros(size(Theta2, 1), 1) Theta2(:,2:end)]; % 10 x 26
  
%Adding regularization term to earlier calculated Theta_grad
Theta1_grad = Theta1_grad + Theta1_grad_reg_term;
Theta2_grad = Theta2_grad + Theta2_grad_reg_term;

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
