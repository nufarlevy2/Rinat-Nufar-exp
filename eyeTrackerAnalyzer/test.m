tic;
c.a = 238*ones(1,10000000);
c.b = 238*ones(1,10000000);
c.c = 238*ones(1,10000000);
for i = 1:1000000
    c.d(i).a = cell(1,ceil(log(i+1)));
    c.d(i).b = cell(1,ceil(log(i+1)));
end
c.e.a = 'asdfasdf';
c.e.b.a = 'asdfasdf';
c.e.b.b = 'asdfasdf';
c.e.b.c = 'asdfasdf';
c.e.b.d = ones(1,100000);
c.e.c = 'asdfasdf';
c.e.d = {123,'sadf',[12.2,1,3,4,5,6,]};
for i= 1:10000
    c.e.e(i).a = cell(6,7);
    c.e.e(i).b = cell(6,7);
    c.e.e(i).c = cell(6,7);
end
toc;

tic;
b.a = ones(1,1000000);
b.b = ones(1,1000000);
b.c = ones(1,1000000);
for i = 1:1000000
    b.d(i).a = ones(1,ceil(log(i+1)));
    b.d(i).b = ones(1,ceil(log(i+1)));
end
b.c = ones(1,1000000);
b.d = ones(1,1000000);
b.e = ones(1,1000000);
b.f = ones(1,1000000);
toc;

tic;save('test.mat','b');toc;

tic;save('test.mat','c');toc;