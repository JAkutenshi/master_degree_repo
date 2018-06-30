size <- c("1K", "4K", "16K", "64K", "256K")

b_real_time <- c(388261.1666667, 3614916.4555555, 14756935.855555499, 56423353.6000001, 223554893.65555558)
b_bytes_per_second <- c(119191.5822219, 113335.1274148, 111146.8408907, 116263.512847, 117270.67721759998)
u_real_time <- c(926387.6666667002, 3451537.5555555, 13698597.166666502, 53578402.955555305, 217454923.5444445)
u_bytes_per_second <- c(110359.78881249999, 118674.81034989997, 119625.07397950001, 122326.72314570002, 120557.75827539999)
r_real_time <- c(1828471.9000000998, 7097240.5222221, 27689148.2111112, 107163885.93333331, 428156444.76666677)
r_bytes_per_second <- c(111978.50719270001, 115874.3708357, 118372.9751462, 122337.87951809999, 122457.3502836)

# yarp_ports_bw
plot(factor(size, levels=size),   b_bytes_per_second / (1024), type="o", col="black", lty=0, ylim=c(100, 130), xlab="", ylab="")
points(factor(size, levels=size), b_bytes_per_second / (1024), col="black", pch="o")
lines(factor(size, levels=size),  b_bytes_per_second / (1024), col="black", lty=1, lwd=2)
points(factor(size, levels=size), u_bytes_per_second / (1024), col="red", pch="x")
lines(factor(size, levels=size),  u_bytes_per_second / (1024), col="red", lty=2, lwd=2)
points(factor(size, levels=size), r_bytes_per_second / (1024), col="blue", pch="v")
lines(factor(size, levels=size),  r_bytes_per_second / (1024), col="blue", lty=3, lwd=2)
title(xlab="Объем данных", ylab="Пропускная способность (КБ/с)")
legend("topleft", legend=c("С буфером", "Без буфера", "RPC"), col=c("black", "red", "blue"), lty=c(1, 2, 3), pch=c("o", "x", "v"), ncol=1)

# yarp_ports_l
plot(factor(size, levels=size),   b_real_time / 1000000, type="o", col="black", lty=0, ylim=c(-10, 450), xlab="", ylab="")
points(factor(size, levels=size), b_real_time / 1000000, col="black", pch="o")
lines(factor(size, levels=size),  b_real_time / 1000000, col="black", lty=1, lwd=2)
points(factor(size, levels=size), u_real_time / 1000000, col="red", pch="x")
lines(factor(size, levels=size),  u_real_time / 1000000, col="red", lty=2, lwd=2)
points(factor(size, levels=size), r_real_time / 1000000, col="blue", pch="v")
lines(factor(size, levels=size),  r_real_time / 1000000, col="blue", lty=3, lwd=2)
title(xlab="Объем данных", ylab="Задержка (мс)")
legend("topleft", legend=c("С буфером", "Без буфера", "RPC"), col=c("black", "red", "blue"), lty=c(1, 2, 3), pch=c("o", "x", "v"), ncol=1)

