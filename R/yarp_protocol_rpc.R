size <- c("1K", "4K", "16K", "64K", "256K")

r_shmem_real_time <- c(307413.0555557, 1257944.8555556, 4677492.4222222, 18909507.533333402, 70715916.2444444)
r_shmem_bytes_per_second <- c(665707.5846997, 654961.9056116, 705576.584699, 696994.7944158999, 741825.4378628001)
r_tcp_real_time <- c(1828471.9000000998, 7097240.5222221, 27689148.2111112, 107163885.93333331, 428156444.76666677)
r_tcp_bytes_per_second <- c(111978.50719270001, 115874.3708357, 118372.9751462, 122337.87951809999, 122457.3502836)
r_fast_tcp_real_time <- c(3206777.779, 6887535.5777777005, 26486211.4222221, 106202812.8111111, 429062746.4)
r_fast_tcp_bytes_per_second <- c(117577.1309322, 119002.95178129998, 123715.5871954, 123425.6590782, 122210.8236037)

# yarp_protocol_rpc_bw
plot(factor(size, levels=size),   r_tcp_bytes_per_second / (1024), type="o", col="black", lty=0, ylim=c(0, 1200), xlab="", ylab="")
points(factor(size, levels=size), r_tcp_bytes_per_second / (1024), col="black", pch="o")
lines(factor(size, levels=size),  r_tcp_bytes_per_second / (1024), col="black", lty=1, lwd=2)
points(factor(size, levels=size), r_shmem_bytes_per_second / (1024), col="red", pch="x")
lines(factor(size, levels=size),  r_shmem_bytes_per_second / (1024), col="red", lty=2, lwd=2)
points(factor(size, levels=size), r_fast_tcp_bytes_per_second / (1024), col="blue", pch="v")
lines(factor(size, levels=size),  r_fast_tcp_bytes_per_second / (1024), col="blue", lty=3, lwd=2)
title(xlab="Объем данных", ylab="Пропускная способность (КБ/с)")
legend("topright", legend=c("tcp", "shmem", "fast_tcp"), col=c("black", "red", "blue"), lty=c(1, 2, 3), pch=c("o", "x", "v"), ncol=1)

# yarp_protocol_rpc_l
plot(factor(size, levels=size),   r_tcp_real_time / (1000000), type="o", col="black", lty=0, ylim=c(0, 500), xlab="", ylab="")
points(factor(size, levels=size), r_tcp_real_time / (1000000), col="black", pch="o")
lines(factor(size, levels=size),  r_tcp_real_time / (1000000), col="black", lty=1, lwd=2)
points(factor(size, levels=size), r_shmem_real_time / (1000000), col="red", pch="x")
lines(factor(size, levels=size),  r_shmem_real_time / (1000000), col="red", lty=2, lwd=2)
points(factor(size, levels=size), r_fast_tcp_real_time / (1000000), col="blue", pch="v")
lines(factor(size, levels=size),  r_fast_tcp_real_time / (1000000), col="blue", lty=3, lwd=2)
title(xlab="Объем данных", ylab="Задержка (мс)")
legend("topleft", legend=c("tcp", "shmem", "fast_tcp"), col=c("black", "red", "blue"), lty=c(1, 2, 3), pch=c("o", "x", "v"), ncol=1)

