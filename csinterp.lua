function csinterpolate(cstable,abscissa)                                                        
print(cstable)

function Entry(b)
count=count+1
inttable[count]=b
end

inttable={}
count=0
f=loadfile(cstable..".cstable")
if f==nil then
  mkcstable(cstable..".xy",cstable..".cstable")
  dofile(cstable..".cstable")
else
  f()
end

--find interval
khi=count
klo=1
repeat
  i=math.floor((khi+klo)/2)
  if inttable[i][1]>abscissa then
    khi=i
  else
    klo=i
    end
  until khi-klo<=1

--calculate ordinate
h=inttable[khi][1]-inttable[klo][1]
a=(inttable[khi][1]-abscissa)/h
b=(abscissa-inttable[klo][1])/h
return a*inttable[klo][2]+b*inttable[khi][2]+
  ((a^3-a)*inttable[klo][3]+(b^3-b)*inttable[khi][3])*(h^2)/6

end

function mkcstable(inp,outp)

function Entry(b)
count=count+1
inttable[count]=b
--print(inttable2[count])
end

inttable={}
count=0
inttable={}

dofile(inp)

u={}
inttable[1][3]=0
u[1]=0
i=count
for j=2,i-1 do
  sig=(inttable[j][1]-inttable[j-1][1])/(inttable[j+1][1]-inttable[j-1][1])
  p=sig*inttable[j-1][3]+2
  inttable[j][3]=(sig-1)/p
  u[j]=(inttable[j+1][2]-inttable[j][2])/(inttable[j+1][1]-inttable[j][1])
    -(inttable[j][2]-inttable[j-1][2])/(inttable[j][1]-inttable[j-1][1])
  u[j]=(6*u[j]/(inttable[j+1][1]-inttable[j-1][1])-sig*u[j-1])/p
  end
qn=0
un=0
inttable[i][3]=(un-qn*u[i-1])/(qn*inttable[i-1][3]+1)
for j=i-1,1,-1 do
  inttable[j][3]=inttable[j][3]*inttable[j+1][3]+u[j]
  end

file.open(outp,"w")
for i=1,count do
--  print("Entry{"..inttable[i][1]..","..inttable[i][2]..","..inttable[i][3].."}")
  file.write("Entry{"..inttable[i][1]..","..inttable[i][2]..","..inttable[i][3].."}\n")
  end
file.close()  

end

--eg print("res2",csinterpolate("dam",3.5)/1000,"Ml" )
  
