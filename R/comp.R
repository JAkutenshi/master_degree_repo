size <- c("1K", "4K", "16K", "64K", "256K", "1M", "4M", "16M", "64M")

ros_tcp_bps <- c(233548707.55889267, 517619176.04281694, 3521025198.331669, 1267576171.691979, 692023701.5569701, 175012270.98146084, 28570435.29598547, 19075255.851903733, 17661296.76422714)
ros_tcp_t <- c(98645086.48662971, 79166648.66358423, 12683969.933360163, 45286113.04486585, 78444876.04642949, 101784359.23296383, 376512161.325, 1282624062.85, 3802408177.5)
mira_tcp_bps <- c(30619.416385, 35082.9929197, 76106.4533962, 740431.6069606, 3901140.533323, 12095738.4135749, 33809618.682818905, 59159007.803795494, 17893148.120781202)
mira_tcp_t <- c(6118035.8, 14367990.7, 22488837.2, 9313783.0, 6840089.6, 8817207.8, 12587785.0, 28643665.2, 60538946.8)
yarp_tcp_bps <- c(119191.5822219, 113335.1274148, 111146.8408907, 116263.512847, 117270.67721759998, 0, 0, 0, 0)
yarp_tcp_t <- c(388261.1666667, 3614916.4555555, 14756935.855555499, 56423353.6000001, 223554893.65555558, Inf, Inf, Inf, Inf)

mira_rpc_t <- c(228600.6841527, 239188.76460180004, 294157.8857295, 599542.3858202, 2757913.4674674, 12549268.2256256, 39024988.17490201, 165140909.2456502, 919168332.6944578)
mira_rpc_bps <- c(864406.1567993, 3397639.180548, 11157012.311954897, 21859116.7171818, 19169743.0961094, 16827996.9726744, 21515874.492444903, 20319110.0058807, 14618378.7690909)
ros_rpc_bps <- c(2150095.0702272914, 8398018.33243535, 31059254.2002196, 119372696.41049369, 153667719.02438125, 379524282.90441144, 581071394.0045922, 669678524.6846191, 486639880.40417826)
req_t <- c(4133046.6, 4149062.7, 4217649.9, 4202854.5, 70529160.0, 16443369.8, 27409928.5, 43983998.4, 293352139.7)
resp_t <- c(62681.1, 74235.6, 82369.6, 631606.4, 595521.6, 10180450.4, 35101911.7, 170881060.4, 806409003.2)
ros_rpc_t <- req_t + resp_t
yarp_rpc_t <- c(1828471.9000000998, 7097240.5222221, 27689148.2111112, 107163885.93333331, 428156444.76666677, Inf, Inf, Inf, Inf)
yarp_rpc_bps <- c(111978.50719270001, 115874.3708357, 118372.9751462, 122337.87951809999, 122457.3502836, 0, 0, 0, 0)

# comp_tcp_l
plot(factor(size, levels=size),   ros_tcp_t / (1000000), type="o", col="black", lty=0, ylim=c(0, 4000), xlab="", ylab="")
points(factor(size, levels=size), ros_tcp_t / (1000000), col="black", pch="o")
lines(factor(size, levels=size),  ros_tcp_t / (1000000), col="black", lty=1, lwd=2)
points(factor(size, levels=size), mira_tcp_t / (1000000), col="blue", pch="x")
lines(factor(size, levels=size),  mira_tcp_t / (1000000), col="blue", lty=2, lwd=2)
points(factor(size, levels=size), yarp_tcp_t / (1000000), col="red", pch="v")
lines(factor(size, levels=size),  yarp_tcp_t / (1000000), col="red", lty=3, lwd=2)
title(xlab="Размер сообщения", ylab="Задержка (мс)")
legend("topleft", legend=c("ROS", "MIRA", "YARP"), col=c("black", "blue", "red"), lty=c(1, 2, 3), pch=c("o", "x", "v"), ncol=1)

# comp_rpc_l
plot(factor(size, levels=size),   ros_rpc_t / (1000000), type="o", col="black", lty=0, ylim=c(0, 1200), xlab="", ylab="")
points(factor(size, levels=size), ros_rpc_t / (1000000), col="black", pch="o")
lines(factor(size, levels=size),  ros_rpc_t / (1000000), col="black", lty=1, lwd=2)
points(factor(size, levels=size), mira_rpc_t / (1000000), col="blue", pch="x")
lines(factor(size, levels=size),  mira_rpc_t / (1000000), col="blue", lty=2, lwd=2)
points(factor(size, levels=size), yarp_rpc_t / (1000000), col="red", pch="v")
lines(factor(size, levels=size),  yarp_rpc_t / (1000000), col="red", lty=3, lwd=2)
title(xlab="Размер сообщения", ylab="Задержка (мс)")
legend("topleft", legend=c("ROS", "MIRA", "YARP"), col=c("black", "blue", "red"), lty=c(1, 2, 3), pch=c("o", "x", "v"), ncol=1)




