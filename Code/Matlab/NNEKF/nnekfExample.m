%Example: a NN model to approximate the sin function
rand('state',0)
N=20;
Ns=100;
x=1.2*randn(N,Ns);
y=sin(x)+0.1*randn(N,Ns);
z=y;
nh=4;
ns=nh*2+nh+1;
theta=randn(ns,1);
P=diag([100*ones(1,nh*2) 10000*ones(1,nh+1)]);
Q=0.001*eye(ns);
R=500*eye(Ns);
% alpha=0.8;
T1=1:N/2;
for k=T1
    [theta,P,z(k,:)]=nnekf(theta,P,x(k,:),y(k,:),Q,R);
end
W1=reshape(theta(1:nh*2),nh,[]);
W2=reshape(theta(nh*2+1:end),1,[]);
T2=N/2+1:N;
for k=T2
    z(k,:)=W2(:,1:nh)*tanh(W1(:,1)*x(k,:)+W1(:,2+zeros(1,Ns)))+W2(:,nh+ones(1,Ns));
end
subplot(211)
plot(x(T1,:),y(T1,:),'ob',x(T1,:),z(T1,:),'.r')
title('training results')
subplot(212)
plot(x(T2,:),y(T2,:),'ob',x(T2,:),z(T2,:),'.r')
title('testing results')

%By Yi Cao at Cranfield University on 10 January 2008
