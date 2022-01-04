#!/bin/sh

# The certificate will expire these many days after the issue date.
DAYS=1500
TEST_CA_DN="/C=CN/ST=HUBEI/L=WUHAN/O=HUST/OU=CA of HUST/CN=CA (SM2)"

TEST_SERVER_DN="/C=CN/ST=HUBEI/L=WUHAN/O=HUST/OU=SERVER of HUST/CN=server sign (SM2)"
TEST_SERVER_ENC_DN="/C=CN/ST=HUBEI/L=WUHAN/O=HUST/OU=SERVER of HUST/CN=server enc (SM2)"

TEST_CLIENT_DN="/C=CN/ST=HUBEI/L=WUHAN/O=HUST/OU=CLIENT of HUST/CN=client sign (SM2)"
TEST_CLIENT_ENC_DN="/C=CN/ST=HUBEI/L=WUHAN/O=HUST/OU=CLIENT of HUST/CN=client sign (SM2)"

# Generating an EC certificate involves the following main steps
# 1. Generating curve parameters (if needed)
# 2. Generating a certificate request
# 3. Signing the certificate request 
# 4. [Optional] One can combine the cert and private key into a single
#    file and also delete the certificate request

mkdir -p ./sm2Certs

echo "创建自签名CA证书 (on curve SM2)"
echo "==============================================================="
gmssl ecparam -name SM2 -out SM2.pem

# gmssl req	创建证书签名请求等功能
# -nodes	    对私钥不进行加密
# -newkey	    创建CSR证书签名文件和RSA私钥文件
# rsa:2048	    指定创建的RSA私钥长度为2048
# -keyout	    创建的私钥文件名称
# -out	        指定CSR输出文件名
# -subj	        指定证书Subject内容

# Subject设定内容说明
#
# 字段	含义	        设定值例
# /C=	Country	        CN
# /ST=	State	        HUBEI
# /L=	Location	    WUHAN
# /O=	Organization	HUST
# /OU=	Organizational	CA
# /CN=	Common Name	    sxy

# 请求CA证书，用SM2.pem加密
# 得到 CA私钥 CA.key.pem 和 CA的请求 CA.req.pem
gmssl req -config ./openssl.cnf -nodes -subj "$TEST_CA_DN" \
    -keyout ./sm2Certs/CA.key.pem \
    -newkey ec:SM2.pem -new \
    -out ./sm2Certs/CA.req.pem

# 用CA证书对请求自签名
# 得到 CA 的证书 CA.cert.pem
gmssl x509 -req -days $DAYS \
    -in ./sm2Certs/CA.req.pem \
    -extfile ./openssl.cnf \
    -extensions v3_ca \
    -signkey ./sm2Certs/CA.key.pem \
    -out ./sm2Certs/CA.cert.pem

# Remove the cert request file (no longer needed)
# 删除请求
rm ./sm2Certs/CA.req.pem

echo "创建server证书 (on elliptic curve SM2)"
echo "=========================================================================="

# 请求SERVER证书，用SM2.pem加密
# 生成 SERVER私钥 SS.key.pem 和 请求 SS.req.pem
gmssl req -config ./openssl.cnf -nodes -subj "$TEST_SERVER_DN" \
    -keyout ./sm2Certs/SS.key.pem \
    -newkey ec:SM2.pem -new \
    -out ./sm2Certs/SS.req.pem

# 用 CA证书 和 CA私钥 对请求 SS.req.pem 进行签名
# 得到服务器证书 SS.cert.pem
gmssl x509 -req -days $DAYS \
    -in ./sm2Certs/SS.req.pem \
    -CA ./sm2Certs/CA.cert.pem \
    -CAkey ./sm2Certs/CA.key.pem \
	-extfile ./openssl.cnf \
	-extensions v3_req \
    -out ./sm2Certs/SS.cert.pem -CAcreateserial

# Remove the cert request file (no longer needed)
rm ./sm2Certs/SS.req.pem

echo "	生成SERVER加密证书 (on elliptic curve SM2)"
echo "  ==================================================================================="
# 请求加密证书
# 获得 加密私钥SE.key.pem 和 加密证书请求SE.req.pem

gmssl req -config ./openssl.cnf -nodes -subj "$TEST_SERVER_ENC_DN" \
    -keyout ./sm2Certs/SE.key.pem \
    -newkey ec:SM2.pem -new \
    -out ./sm2Certs/SE.req.pem

# 用 CA证书 和 CA私钥 对 SERVER加密请求 签名
# 得到 SERVER加密证书SE.cert.pem
gmssl x509 -req -days $DAYS \
    -in ./sm2Certs/SE.req.pem \
    -CA ./sm2Certs/CA.cert.pem \
    -CAkey ./sm2Certs/CA.key.pem \
	-extfile ./openssl.cnf \
	-extensions v3enc_req \
    -out ./sm2Certs/SE.cert.pem -CAcreateserial

# Remove the cert request file (no longer needed)
rm ./sm2Certs/SE.req.pem


echo "生成CLIENT证书 (on elliptic curve SM2)"
echo "=========================================================================="
# 请求CLIENT证书
# 得到 CLIENT私钥CS.key.pem 和CLIENT请求CS.req.pem
gmssl req -config ./openssl.cnf -nodes -subj "$TEST_CLIENT_DN" \
	     -keyout ./sm2Certs/CS.key.pem \
	     -newkey ec:SM2.pem -new \
	     -out ./sm2Certs/CS.req.pem

# 用 CA证书 和 CA私钥 对CLIENT请求 签名
# 得到 CLIENT证书CS.cert.pem
gmssl x509 -req -days $DAYS \
    -in ./sm2Certs/CS.req.pem \
    -CA ./sm2Certs/CA.cert.pem \
    -CAkey ./sm2Certs/CA.key.pem \
	-extfile ./openssl.cnf \
	-extensions v3_req \
    -out ./sm2Certs/CS.cert.pem -CAcreateserial

# Remove the cert request file (no longer needed)
rm ./sm2Certs/CS.req.pem


echo "	生成CLIENT加密证书 (on elliptic curve SM2)"
echo "	==================================================================================="
# 请求CLIENT加密证书
# 得到 CLIENT加密私钥CE.key.pem 和 CLIENT加密请求CE.req.pem
gmssl req -config ./openssl.cnf -nodes -subj "$TEST_CLIENT_ENC_DN" \
	     -keyout ./sm2Certs/CE.key.pem \
	     -newkey ec:SM2.pem -new \
	     -out ./sm2Certs/CE.req.pem

# 用CA证书 和 CA私钥 对CLIENT加密请求 签名
# 得到 CLEINT加密证书CE.cert.pem
gmssl x509 -req -days $DAYS \
    -in ./sm2Certs/CE.req.pem \
    -CA ./sm2Certs/CA.cert.pem \
    -CAkey ./sm2Certs/CA.key.pem \
	-extfile ./openssl.cnf \
	-extensions v3enc_req \
    -out ./sm2Certs/CE.cert.pem -CAcreateserial

# Remove the cert request file (no longer needed)
rm ./sm2Certs/CE.req.pem


