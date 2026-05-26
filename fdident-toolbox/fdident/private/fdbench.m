function performance=fdbench

persistent time
if isempty(time)
  %Measure relative performance of machine
  %       Helper function of autoorder_demos
  % LU, n = 1000.
  lu(0);
  if strncmp(version,'5',1)
    n = 1000*0.2;
  else
    n = 1000*0.7;
  end
  randn('state',0);
  A = randn(n,n);
  X = A;
  clear X
  tic
  X = lu(A);
  time1 = toc;
  time=time1;
  clear A X
  
  % FFT, n = 2^20.  Do it twice to roughly match LU time.
  fft(0);
  if strncmp(version,'5',1)
    n = 2^20/16;
  else
    n = 2^20/4;
  end

  y = ones(1,n)+i*ones(1,n);
  clear y
  randn('state',1);
  x = randn(1,n);
  tic
  y = fft(x);
  clear y
  y = fft(x);
  time2 = toc;
  time=time+toc;
end
if strncmp(version,'5',1)
  performance=6.7/time;
else
  performance=19/time;
end
