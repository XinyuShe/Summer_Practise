all:
	sudo g++ server.cpp -I/usr/local/gmssl/include -L/usr/local/gmssl/lib -lssl -lcrypto -ldl -lpthread -o server
	sudo g++ client.cpp -I/usr/local/gmssl/include -L/usr/local/gmssl/lib -lssl -lcrypto -ldl -lpthread -o client
clean:
	sudo rm client server *.pem
