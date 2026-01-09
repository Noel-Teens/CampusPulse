import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../models/user_model.dart';
import '../../../core/constants/app_colors.dart';
import 'add_faculty_screen.dart';

class ManageFacultyScreen extends StatelessWidget {
  const ManageFacultyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Faculty"),
        backgroundColor: AppColors.darkSlate,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddFacultyScreen()),
        ),
        label: const Text("Add Faculty"),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.tealAccent,
      ),
      body: StreamBuilder<List<UserModel>>(
        // We can use a direct stream from Firestore here for simplicity
        stream: authController.getUsersByRole(UserRole.faculty),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No faculty accounts found."));
          }

          final faculty = snapshot.data!;
          return ListView.builder(
            itemCount: faculty.length,
            itemBuilder: (context, index) {
              final user = faculty[index];
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(user.name ?? "No Name"),
                subtitle: Text(user.email),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () =>
                      _confirmDelete(context, authController, user),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    AuthController auth,
    UserModel user,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Account?"),
        content: Text(
          "Are you sure you want to delete ${user.name}'s faculty account? This only removes their data record.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await auth.deleteUser(user.uid);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
