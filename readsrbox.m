function value = readsrbox(srboxportobj)

if get(srboxportobj,'BytesAvailable')
    input = fread(srboxportobj,get(srboxportobj,'BytesAvailable'));
    value = input(1);
else
    value = 0;
end