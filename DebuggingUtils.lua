SF = {
  debug = false
}

function SF:log(msg)
  if self.debug then
    print(msg)
  end
end
