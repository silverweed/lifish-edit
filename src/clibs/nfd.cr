# Bridge for libnfd.so
@[Link(ldflags: "-lnfd `pkg-config --libs gtk+-3.0`")]
lib LibNFD
	enum Result
		ERROR
		OKAY
		CANCEL
	end

	fun open_dialog = NFD_OpenDialog(filterList : UInt8*, defaultPath : UInt8*, outPath : UInt8**) : Result
	fun save_dialog = NFD_SaveDialog(filterList : UInt8*, defaultPath : UInt8*, outPath : UInt8**) : Result
end
