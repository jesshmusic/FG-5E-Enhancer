--
--
-- slash command
--
--

function onInit()
  if User.isHost()  then
    Comm.registerSlashHandler("readycheck", ConnectionManagerADND.processReadyCheck);
  	Comm.registerSlashHandler("dsave", TokenSaveGraphics.deleteSaveWidgets, "5E Enhancer: Delete saves");
  end
end
