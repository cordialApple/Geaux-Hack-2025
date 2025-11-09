class_name quest extends questline

func questStart() -> void:
	if questState == questStatus.Uncompleted:
		questState = questStatus.InProgress
		
		

func questFinished() -> void:
	questState = questStatus.Completed
	
