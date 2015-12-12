# Bridge for libnfd.so
@[Link(ldflags: "-L./foreign -lnfd `pkg-config --libs gtk+-3.0`")]
lib NFD
	enum Result
		ERROR
		OKAY
		CANCEL
	end

	fun open_dialog = NFD_OpenDialog(filterList : UInt8*, defaultPath : UInt8*, outPath : UInt8**) : Result
	fun save_dialog = NFD_SaveDialog(filterList : UInt8*, defaultPath : UInt8*, outPath : UInt8**) : Result
end
