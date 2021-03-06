## Elastic net: use a fixed sequence of 100 lambda values

# Generate some example training data
set.seed(11)
n = 200; p = 500; s = 10
x = matrix(rnorm(n*p),n,p)
beta = c(rnorm(s),rep(0,p-s)) 
y = x %*% beta + rnorm(n)

# Generate some example test data
n0 = 1000
x0 = matrix(rnorm(n0*p),n0,p)
y0 = x0 %*% beta + rnorm(n0)

# Grab a fixed lambda sequence from one call to glmnet, then
# define elastic net training and prediction functions
if (!require("glmnet",quietly=TRUE)) {
  stop("Package glmnet not installed (required for this example)!") 
}
out.gnet = glmnet(x,y,alpha=0.9,nlambda=100,lambda.min.ratio=1e-4)
lambda = out.gnet$lambda
funs = elastic.funs(gamma=0.9,lambda=lambda)

# Split conformal inference 
out.split = conformal.pred.split(x, y, x0, alpha=0.1,
  train.fun=funs$train, predict.fun=funs$predict)

y0.mat = matrix(rep(y0,ncol(out.split$lo)),nrow=n0)
cov.split = colMeans(out.split$lo <= y0.mat & y0.mat <= out.split$up)
len.split = colMeans(out.split$up - out.split$lo)
err.split = colMeans((y0.mat - out.split$pred)^2)

# Compare to parametric intervals from oracle linear regression
lm.orac = lm(y~x[,1:s])
out.orac = predict(lm.orac, list(x=x0[,1:s]),
  interval="predict", level=0.9)

cov.orac = mean(out.orac[,"lwr"] <= y0 & y0 <= out.orac[,"upr"])
len.orac = mean(out.orac[,"upr"] - out.orac[,"lwr"])
err.orac = mean((y0 - out.orac[,"fit"])^2)
  
# Plot average coverage 
plot(log(lambda),cov.split,type="l",ylim=c(0,1),
     xlab="log(lambda)",ylab="Avg coverage",
     main=paste0("Split conformal + elastic net (fixed lambda sequence):",
       "\nAverage coverage"))
points(log(lambda),cov.split,pch=20)
abline(h=cov.orac,lty=2,col=2)
legend("bottomleft",col=1:2,lty=1:2,
       legend=c("Split conformal","Oracle"))

# Plot average length
plot(log(lambda),len.split,type="l",
     ylim=range(len.split,len.orac),
     xlab="log(lambda)",ylab="Avg length",
     main=paste0("Split conformal + elastic net (fixed lambda sequence):",
       "\nAverage length"))
points(log(lambda),len.split,pch=20)
abline(h=len.orac,lty=2,col=2)
legend("topleft",col=1:2,lty=1:2,
       legend=c("Split conformal","Oracle"))

# Plot test error
plot(log(lambda),err.split,type="l",
     ylim=range(err.split,err.orac),
     xlab="log(lambda)",ylab="Test error",
     main=paste0("Split conformal + elastic net (fixed lambda sequence):",
       "\nTest error"))
points(log(lambda),err.split,pch=20)
abline(h=err.orac,lty=2,col=2)
legend("topleft",col=1:2,lty=1:2,
       legend=c("Split conformal","Oracle"))

####################

cat("Type return to continue ...\n")
tmp = readLines(n=1)

## Elastic net: alternate way, use a dynamic sequence of 100 lambda values

# Elastic net training and prediction functions
funs = elastic.funs(gamma=0.9,nlambda=100)

# Split conformal inference 
out.split = conformal.pred.split(x, y, x0, alpha=0.1,
  train.fun=funs$train, predict.fun=funs$predict)

y0.mat = matrix(rep(y0,ncol(out.split$lo)),nrow=n0)
cov.split = colMeans(out.split$lo <= y0.mat & y0.mat <= out.split$up)
len.split = colMeans(out.split$up - out.split$lo)
err.split = colMeans((y0.mat - out.split$pred)^2)

# Compare to parametric intervals from oracle linear regression
lm.orac = lm(y~x[,1:s])
out.orac = predict(lm.orac, list(x=x0[,1:s]),
  interval="predict", level=0.9)

cov.orac = mean(out.orac[,"lwr"] <= y0 & y0 <= out.orac[,"upr"])
len.orac = mean(out.orac[,"upr"] - out.orac[,"lwr"])
err.orac = mean((y0 - out.orac[,"fit"])^2)
  
# Plot average coverage 
plot(log(length(cov.split):1),cov.split,type="l",ylim=c(0,1),
     xlab="log(lambda rank) (i.e., log(1)=0 is smallest)",
     ylab="Avg coverage",
     main=paste0("Split conformal + elastic net (dynamic lambda sequence):",
       "\nAverage coverage"))
points(log(length(cov.split):1),cov.split,pch=20)
abline(h=cov.orac,lty=2,col=2)
legend("bottomleft",col=1:2,lty=1:2,
       legend=c("Split conformal","Oracle"))

# Plot average length
plot(log(length(len.split):1),len.split,type="l",
     ylim=range(len.split,len.orac),
     xlab="log(lambda rank) (i.e., log(1)=0 is smallest)",
     ylab="Avg length",
     main=paste0("Split conformal + elastic net (dynamic lambda sequence):",
       "\nAverage length"))
points(log(length(len.split):1),len.split,pch=20)
abline(h=len.orac,lty=2,col=2)
legend("topleft",col=1:2,lty=1:2,
       legend=c("Split conformal","Oracle"))

# Plot test error
plot(log(length(err.split):1),err.split,type="l",
     ylim=range(err.split,err.orac),
     xlab="log(lambda rank) (i.e., log(1)=0 is smallest)",ylab="Test error",
     main=paste0("Split conformal + elastic net (dynamic lambda sequence):",
       "\nTest error"))
points(log(length(err.split):1),err.split,pch=20)
abline(h=err.orac,lty=2,col=2)
legend("topleft",col=1:2,lty=1:2,
       legend=c("Split conformal","Oracle"))

####################

cat("Type return to continue ...\n")
tmp = readLines(n=1)

## Elastic net: cross-validate over a sequence of 100 lambda values

# Elastic net training and prediction functions
funs = elastic.funs(gamma=0.9,nlambda=100,cv=TRUE)

# Split conformal inference 
out.split = conformal.pred.split(x, y, x0, alpha=0.1,
  train.fun=funs$train, predict.fun=funs$predict)

cov.split = mean(out.split$lo <= y0 & y0 <= out.split$up)
len.split = mean(out.split$up - out.split$lo)
err.split = mean((y0 - out.split$pred)^2)

# Compare to parametric intervals from oracle linear regression
lm.orac = lm(y~x[,1:s])
out.orac = predict(lm.orac, list(x=x0[,1:s]),
  interval="predict", level=0.9)

cov.orac = mean(out.orac[,"lwr"] <= y0 & y0 <= out.orac[,"upr"])
len.orac = mean(out.orac[,"upr"] - out.orac[,"lwr"])
err.orac = mean((y0 - out.orac[,"fit"])^2)

tab = matrix(c(cov.split,len.split,err.split,
  cov.orac,len.orac,err.orac),ncol=2)
colnames(tab) = c("Split conformal","Oracle")
rownames(tab) = c("Avg coverage","Avg length","Test error")
tab
