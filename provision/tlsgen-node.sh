# arguments
IP=$1

# workdir
cd keys
rm -rf $1 && true
mkdir $1
cd $1

# extfile
echo "subjectAltName = IP:${IP}" > extfile.cnf
echo "extendedKeyUsage = clientAuth,serverAuth" >> extfile.cnf

# server cert
openssl genrsa -out server-key.pem 4096
openssl req -subj "/CN=server" -new -key server-key.pem -out server.csr
openssl x509 -req -days 365 -sha256 -in server.csr -out server-cert.pem \
  -CA ../ca.pem -CAkey ../ca-key.pem -CAcreateserial -extfile extfile.cnf
