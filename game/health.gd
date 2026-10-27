class_name Health extends HBoxContainer

func set_value(val: int):
	var i := 1
	for ch in get_children():
		var con_ch: Control = ch
		con_ch.visible = i <= val
		i += 1
		
