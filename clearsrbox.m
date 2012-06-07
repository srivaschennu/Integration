function clearsrbox(srboxportobj)

while get(srboxportobj,'BytesAvailable')
    fread(srboxportobj,get(srboxportobj,'BytesAvailable'));
end