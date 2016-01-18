# workdir
mkdir keys && true
cd keys
rm -rf * && true

# ca cert
openssl genrsa -out ca-key.pem 4096
openssl req -subj "/CN=server" -new -x509 -days 365 -key ca-key.pem -out ca.pem

# extfile
echo "extendedKeyUsage = clientAuth" >> extfile-client.cnf

# client cert
openssl genrsa -out key.pem 4096
openssl req -subj '/CN=ca' -new -key key.pem -out client.csr
openssl x509 -req -days 365 -sha256 -in client.csr -out cert.pem \
  -CA ca.pem -CAkey ca-key.pem -CAcreateserial -extfile extfile-client.cnf
