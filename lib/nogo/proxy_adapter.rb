module NoGo
  class ProxyAdapter
    instance_methods.each do |m| 
      undef_method m unless m =~ /(^__|^send$|^object_id$)|^extend|^tap/ 
    end  
  end
end