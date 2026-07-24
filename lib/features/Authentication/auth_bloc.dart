import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quiz_app/core/controllers/auth_controller.dart';
import 'package:quiz_app/core/services/token_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    //Login Event Handling
    on<LoginButtonClicked>((event, emit) async{
      if(event.formkey) {
        emit(LoadingState());
       final response= await AuthController().login(event.email, event.password);
       if(response['success'] != true){
         emit(ErrorState(message: response['message'].toString()));
         return;
       }
       await TokenService.saveTokens(accessToken: response['accessToken'] as String, refreshToken: response['refreshToken']as String, role: response['role']as String);
       String? role=await TokenService.getRole();
       emit(LoginSuccessState(role:role));

      }
    });
    on<CreateAccountClicked>((event, emit) {
      emit(CreateAccountState());
    });
    //SignUpEventHandling
    on<NextButtonClickedEvent>((event,emit){
      emit(NextClickedState());
    });
    on<SignUpEvent>((event,emit)async{
      if(event.formkey) {
        emit(LoadingState());
        final response = await AuthController().signUp(
            event.name, event.email, event.password, event.role);
        print(response['success']);
        if (response['success'] != true) {
          emit(ErrorState(message: response['message'].toString()));
          return;
        }
        emit(SignUpSuccessState());
      }
    });
    //OtpEventHandling
    on<VerifyButtonClicked>((event,emit)async{

         if(event.key){
           emit(LoadingState());
           final response=await AuthController().verifyOtp(event.email,event.otp,event.role);
           if(response['success']!=true){
             emit(ErrorState(message: response['message'].toString()));
             return;
           }
           emit(OtpSuccessState());
         }
    });
  }
}


