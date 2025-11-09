class_name Levels extends Node


@export_group("Quests")
@export var currentLevel: int
@export var xpToNext: int

enum questStatus{
	Uncompleted,
	Completed,
	Inprogress
}

@export var questState: questStatus = questStatus.Uncompleted

@export_group("Reward Settings")
@export var reward: int
