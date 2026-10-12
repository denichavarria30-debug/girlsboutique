import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _db.collection('usuarios').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }

  Future<UserModel> loginUser({
    required String correo,
    required String password,
  }) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: correo,
      password: password,
    );
    final user = await getUserData(cred.user!.uid);
    return user!;
  }

  Future<UserModel> registerUser({
    required String nombre,
    required String telefono,
    required String correo,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: correo,
      password: password,
    );

    // si inicia con ese correo es administradora de lo contrario cliente
    final String rolAsignado =
        (correo.trim().toLowerCase() == 'denichavarria30@gmail.com')
            ? 'admin'
            : 'cliente';

    final newUser = UserModel(
      uid: cred.user!.uid,
      nombre: nombre,
      telefono: telefono,
      correo: correo,
      rol: rolAsignado,
    );

    await _db.collection('usuarios').doc(cred.user!.uid).set(newUser.toMap());
    return newUser;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
