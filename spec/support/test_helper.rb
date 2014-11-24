def wait_and_do(wait_second)
  begin
    timeout(wait_second) do
      loop do
        if yield
          break
        else
          sleep 0.1
        end
      end
    end
  end
end
