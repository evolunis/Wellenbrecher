import 'package:firebase_database/firebase_database.dart';

FirebaseDatabase database = FirebaseDatabase.instance;

write(String place, Map value) async {
  DatabaseReference ref = database.ref(place);
  return ref.set(value);
}

read(String place) async {
  DatabaseReference ref = database.ref(place);
  var snapshot = await ref.get();
  return snapshot.value ;
}
