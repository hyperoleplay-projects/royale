createProgressBar = function(_time, _text)
  if not _time or math.floor(_time) <= 0 then 
      return
  end
  
  _time = math.floor(_time)
  
  if not _text then
      _text = "progresso"
  end
  
  if _time > 1000 then
      _time = (_time / 1000)
  end
  
  SendNUIMessage({ action = "createProgressBar", time = _time, text = _text })
end

exports("createProgressBar",createProgressBar)

removeProgressBar = function()
  SendNUIMessage({ action = "removeProgressBar" })
end

exports("removeProgressBar",removeProgressBar)