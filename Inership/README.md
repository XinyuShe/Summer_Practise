# To compile the server and the client
cd ~/Desktop/inership/mk_tls_cert
make clean
make

# To generate the certificates
cd mk_tls_cert
make clean
make

# To run the server and the client
cd ..
Terminel1:
    ./server

Terminel2:
    ./client