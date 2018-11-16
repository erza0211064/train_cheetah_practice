clear
%loading document and picture
load('TrainingSamplesDCT_8.mat')
[BG_x, BG_y] = size(TrainsampleDCT_BG);  %grass has a training sample 1053
[FG_x, FG_y] = size(TrainsampleDCT_FG);  %cheetah has a training sample 205

zigzag = load('Zig-Zag Pattern.txt') + 1; %change 0~63 into 1~64

img = imread('cheetah.bmp'); %load picture
img = im2double(img); %change picture to double matrix
[x, y] = size(img); %x stands for cheetah image row and y for col

img_mask = imread('cheetah_mask.bmp');
img_mask = im2double(img_mask);

% Finding reasonable prior probility of grass and cheetah
Py_grass = BG_x/(BG_x + FG_x); %Py(grass) = 0.8081
Py_cheetah = FG_x/(BG_x + FG_x); %Py(cheetah) = 0.1919

%draw grass histogram
BG = findMax(TrainsampleDCT_BG, BG_x); %find second max index
figure(1);
h1 = histogram(BG,1:65); %plot the histogram of grass and set bin as 64 segment
count_BG = h1.Values; %put each value of bin into an array
bin_BG = count_BG/BG_x; % caluate the probability of each bin
bar(bin_BG) % plot the result
xlabel('X index'), ylabel('probability'), title('P(x|grass) histogram')

for i=1:64
    BDR_grass(i,1) = double(count_BG(i)/BG_x*Py_grass); %calulate Px|y(x|grass)*Py(grass)/P(x)
end

%draw cheetah histogram
FG = findMax(TrainsampleDCT_FG,FG_x); %find second max index

figure(2);
h2 = histogram(FG,1:65);
count_FG = h2.Values;
bin_FG = h2.BinCounts;
bin_FG = bin_FG/FG_x;
bar(bin_FG)
xlabel('X index'), ylabel('probability'), title('P(x|cheetah) histogram')

for i=1:64
    BDR_cheetah(i,1) = double(count_FG(i)/FG_x*Py_cheetah); %calulate Px|y(x|cheetah)*Py(cheetah)/P(x)
end
% find out the place where cheetah P is larger then grass P and use on the testing data
k = 1;
for i=1:64
    if BDR_cheetah(i) > BDR_grass(i)
        printMat(k) = i;
        k = k + 1;
    end
end
%making the cheetah imgae(testing data) into the same form of training data
k = 1;
for i=1:x-7
    for j=1:y-7
        blk = img(i:i+7,j:j+7); % split the cheetah into 8x8 block
        blkDCT = dct2(blk); % do dct
        blkDCTZigZag(zigzag) = blkDCT; % reshape with zigzag
        testingMatrix(k,:) = blkDCTZigZag; % put the result into a new matrix
        k = k + 1;
    end
end
[row col] = size(testingMatrix);
secLarge = findMax(testingMatrix, row); % find second large index
cheetahImg = zeros(x,y); % generate a matrix where we print a result
k = 1;
for i=1:x-7
    for j=1:y-7
        if ismember(secLarge(k), printMat) % if the testing image match the training Matrix which indicated cheetah, put 1
            cheetahImg(i,j) = 1;
        else
            cheetahImg(i,j) = 0; % if not, put zero
        end
        k = k + 1;
    end
end

figure;
imagesc(cheetahImg)
colormap(gray(255))

% caluate the error
error = 0;
for i=1:x
    for j=1:y
        if img_mask(i,j) ~= cheetahImg(i,j) % img_mask is the correct answer, compare the difference between the answer and our answer
            error = error + 1; % if the pixel does not match, error plus one
        end
    end
end

error_percentage = error*100/(x*y) % caluate the percentage of error

            
% function y = findMax(mat, mat_row)
%     for i = 1:mat_row
%        tmp = abs(mat(i, 2:end)); %take absolute value, discard the first value and start with the second one
%        [val idx] = max(tmp); % find the max number and its index
%        y(i) = idx + 1; % add the max index to the array
%     end
% end

function y = findMax(mat, mat_row)
    for i = 1:mat_row
       tmp = abs(mat(i, 1:end)); %take absolute value, discard the first value and start with the second one
       [val idx] = max(tmp); % find the max number and its index
       tmp(idx) = []; % throw away
       [val idx] = max(tmp); % find the second max number
       y(i) = idx + 1; % add the max index to the array
    end
end
