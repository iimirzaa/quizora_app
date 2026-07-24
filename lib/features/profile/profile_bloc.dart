import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quiz_app/core/controllers/auth_controller.dart';
import 'package:quiz_app/core/services/token_service.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LogoutButtonClicked>((event, emit) async{
      emit(LoadingState());
      final String? refreshToken=await TokenService.getRefreshToken();
      final response=await AuthController().logout(refreshToken!);
      if(response['success']!= true){
      emit(ErrorState(msg:response["message"]as String));
      return;
      }
      await TokenService.clearTokens();
      emit(LogoutSuccessState());
    });
  }
}
