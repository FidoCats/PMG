extends Node



signal TimeAdvance(H: int, M: int)
signal TimeChange(H: int, M: int)
signal CycleChange(NewCycle: Cycles)
signal WeatherChange(NewWeather: Weather)

enum Cycles {Morning = 0, Day = 1, Evening = 2, Night = 3}
var CurrentCycle: Cycles = 0 as Cycles
enum Weather {None = 0, Fog = 1, Rain = 2, Downpour = 3}
var CurrentWeather: Weather = 0 as Weather
var Minutes: int = 59
var Hours: int = 5



@rpc("any_peer","call_local")
func AddTime(H: int = 0 , M: int = 1):
	Hours += H
	Minutes += M
	if Minutes > 59:
		Minutes = 0
		Hours += 1
	if Hours > 23:
		Minutes = 0
		Hours = 0
	TimeAdvance.emit(H,M)
	TimeChange.emit(Hours, Minutes)
	#print(Hours,":",Minutes)



@rpc("any_peer","call_local")
func SetTime(H: int = 0, M: int = 0):
	Hours = H
	Minutes = M
	TimeChange.emit(Hours, Minutes)
	print("Time set to ",Hours,":",Minutes)



func UpdateCheck(H,M):
	match H:
		6:
			ChangeCycle.rpc(Cycles.Morning)
		12:
			ChangeCycle.rpc(Cycles.Day)
		18:
			ChangeCycle.rpc(Cycles.Evening)
		24:
			ChangeCycle.rpc(Cycles.Night)
	
	print("Updated!!!")



@rpc("any_peer","call_local")
func ChangeCycle(DesiredCycle: Cycles):
	CurrentCycle = DesiredCycle
	CycleChange.emit(CurrentCycle)
	#if CurrentCycle == Cycles.Morning:
	print(CurrentCycle," ",Cycles.Morning)


@rpc("any_peer","call_local")
func ChangeWeather(DesiredWeather: Weather):
	CurrentWeather = DesiredWeather
	WeatherChange.emit(CurrentWeather)
