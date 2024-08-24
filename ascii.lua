for i = 0, 255 do
    if i % 20 == 0 then
        print('\n'..i)
    elseif i % 5 == 0 then
        term.write('    ')
    end
    term.write(string.char(i)..' ')
end
