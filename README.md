![깃허브용](https://user-images.githubusercontent.com/25628769/111748141-81144b80-88d3-11eb-8547-df55d8da8298.png)
# 왕국타이머

[App store](https://apps.apple.com/us/app/%EC%99%95%EA%B5%AD%ED%83%80%EC%9D%B4%EB%A8%B8/id1556230748)  
본격 생산물 관리 타이머 앱(일생생활에도 사용가능!)  

<img width="220" alt="page0" src="https://user-images.githubusercontent.com/25628769/118390490-47a95380-b66a-11eb-8d9c-926fd35b11cc.png"> <img width="220" alt="page1" src="https://user-images.githubusercontent.com/25628769/118390492-49731700-b66a-11eb-92dc-68e2eacb584e.png"> <img width="220" alt="page2" src="https://user-images.githubusercontent.com/25628769/118390495-4b3cda80-b66a-11eb-9b4a-26174cf3bc0b.png"> 
## 개발 초점


코코아터치를 배우는 단계에서, 배운 것들을 최대한 활용하려고 노력함.  
특히 MVC 디자인 패턴에 맞추어 Model, View, Controller의 역할을 나누려 노력함.  
그 외 초점을 맞춘 것은 아래와 같음.

- '기능'만 하는 앱에서 그치지 않게 최대한 설계하고 구조화하려고 노력.
- 상수, 구조체 type property, Enum을 활용하여 리터럴 값의 사용을 최대한 줄임.
- TaskTimer 객체는 delegate 패턴으로 남은 초, 타이머 상태가 갱신될 때마다 알리도록 구현.  
  그래서 TaskTimerCell이 그 알림을 받아 자신의 backgroundColor, title 등을 바꿈.
- 앱에서 생성한 타이머를 `Timer.scheduledTimer(withTimeInterval:repeats:block)` API를 통해 갱신하는데,  
  메인 화면을 벗어날 경우 Timer 객체를 invalidate 하고 이후 메인 화면으로 돌아올 경우 다시 Timer를  
  스케쥴링 하는 방식으로 앱 내 타이머의 동작을 최적화함.
- HIG에 명시된 내용에 맞추어 알람 권한 획득 시점을 설정함.
- CoreData를 사용하여 데이터를 관리. 이때 DAO 객체를 활용하여 데이터를 fetch하거나 저장할 때의 타입변환을 감추려 노력함.
- 내비게이션 바, 탭 바를 커스터마이징하여 일관성 있는 UI를 구성함.
- UIViewController, UIColor에는 Extension으로 필요한 함수를 추가하여 활용.
- 네이밍을 짧게 하기 보단 길더라도 의미가 명확할 수 있도록 노력함.
- Trello의 칸반보드를 활용하여 개발 사항을 관리함.

## 부족한 점. 아쉬운 점.

공부하면서 개인 프로젝트로 앱을 만들다보니 아쉬운 점이 많았음. 특히 코드 작성이나 UIKit 프레임워크 사용에 있어서  
올바른 사용법으로 개발하였는지가 의문이 들었음.

- 효율적인 코드를 작성하였는가? 적합한 코드를 작성하였는가? 이해하기 쉬운 코드를 작성하였는가? 등에 대해서는 많이 부족함.  
  현업자라면, 다른 개발자라면 어떻게 코드를 작성했을지에 대한 의문점이 많이 생김. delegate 패턴을 맞게 사용하는 것인지,  
  네이밍부터 옵셔널 바인딩, guard 사용, 변수 할당 시점, 프로퍼티의 옵셔널 유무 등 스스로 판단하고 결정한 사항들에 대해  
  옳은지 옳지 않은지 제대로된 평가를 받지 못하였음. 교내 동아리에서 다른 개발자분들과 협업할 기회를 찾을 예정.
- 개발일정이 늘어짐. 배우면서 개발하다보니 doc을 읽거나 구글링하는 데에 많은 시간이 소비됨.
- 실사용자 테스트를 거의 하지 않아서 유용성에 의문이 듬.
- CollectionViewLayout에 대한 명확한 이해가 부족했음.
- Constraints를 맞게 사용했는지 잘 모르겠음. 어떨 때는 스토리보드에서 constraints를 레이아웃을 잡고,  
  어떨 때는 코드로(collectionViewLayout의 inset 계산할 때) 레이아웃을 잡는데 올바른 사용법을 아직 익히지 못함.
- 화면 전환을 최대한 코드로 하려다보니(배우는 단계라서 의도적으로) 스토리보드의 생산성을 충분히 누리지 못했음.
  세그웨이로(id는 동사형 띄워쓰기, prepare문에서 switch 활용) 전환을 최대한 누리자.
- Timer 스케쥴링은 전부 main 쓰레드에 몰아서 함. 정확하게 몇 개의 Timer를 스케쥴링해도 무리가 없는지를 정확하게 파악하지 못하였음.
- HIG에 맞게 개발하였는지 확인하지 않음. 차차 읽어나가서 HIG에 생각의 기준을 맞출 수 있도록 노력할 것.
- 테스트 코드를 적용하지 않았음. UI 테스트에 대해서 공부한 후 새로운 프로젝트에 적용해볼 예정.
