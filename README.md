# YJWeather


## 앱 설명


> ‘Sunny Day’는 실시간 날씨, 대기오염 정보 그리고 날씨 예보를 제공하는 애플리케이션입니다. 자주 확인하는 정보만으로 깔끔하게 구현하였습니다.


![Sunny Day](https://github.com/0jun0815/YJWeather/blob/master/Images/Sunny%20Day.png)


### 기능
* 리스트 형식으로 지역별 날씨 상태를 제공합니다. 상단에는 현재 위치 기반 정보 그리고 추가된 지역순으로 보여줍니다.
* 리스트에서 지역을 클릭하면 상세 보기를 확인할 수 있습니다.
* 요약 보기에서는 실시간 하늘 상태, 현재 온도, 최고/최저 온도, 습도, 풍향/풍속, 강수확률, 미세먼지 등급을 확인할 수 있습니다.
* 상세 보기에서는 24시간 동안의 시간대별 날씨 예보와 통합대기 환경, 미세먼지, 초미세먼지, 일산화탄소, 이산화탄소, 오존, 아황산가스 등급과 농도를 확인할 수 있습니다.
* 하단의 버튼으로 지역을 추가, 제거할 수 있습니다.


### 데이터 출처
* 기상청(동네예보 정보)
* 한국환경공단(대기오염 정보, 측정소 정보)


### 앱스토어: [Sunny Day](https://itunes.apple.com/kr/app/sunny-day/id1385458263?mt=8)


&nbsp;
## 리팩토링
### 리팩토링을 계획한 이유
그동안 프로젝트에 참여하면서 가장 우선시했던 것은 완성이었다. 하지만 네이버 테크 밋업, 부스트코스 등을 참여하며 만났던 선배 개발자분들의 조언은 단순한 복사 붙여 넣기 보단 원리를 알고 공부를 하는 것, 그리고 왜 그렇게 코드를 만들었고 더 나은 방법은 없는지에 대해 많은 생각을 해보는 것. 즉, '어떻게'보다는 '왜' 그 코드를 사용했는지가 중요하다는 것이었다.


거기에 네이버 커넥트재단의 부스트코스 에이스 과정에 참여를 하며 새로운 기술과 세련된 코드를 배웠다. 따라서 배운 것들을 적용하여 해당 프로젝트를 좀 더 나은 코드로 개선하고 구현한 기능들에 대한 명확한 이해를 해보자는 목표로 리팩토링을 계획하였다.


### 리팩토링 목표
리팩토링 진행에 앞서 다음과 같은 목표를 세웠다. 공부한 내용들은 [블로그](https://0jun0815.github.io)에 정리해둘 것이다. 
* 코드 간결화 및 기능의 세분화
* 프로토콜 지향 프로그래밍
* CoreData에 충분한 이해 ([https://0jun0815.github.io/core-data](https://0jun0815.github.io/core-data))
* Alamofire의 장단점 및 코드 분석
* Instrument 사용해보기
* UnitTest 사용해보기




&nbsp;
&nbsp;      
### [by. 0junChoi](https://github.com/0jun0815) email: <0jun0815@gmail.com>
