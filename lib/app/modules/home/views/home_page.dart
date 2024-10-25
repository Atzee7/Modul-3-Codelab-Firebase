import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_page.dart'; // Import LoginPage

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _taskController = TextEditingController();
  final CollectionReference _tasksCollection = FirebaseFirestore.instance.collection('tasks');

  // Fungsi untuk menambah tugas ke Firestore
  Future<void> _addTask(String task) async {
    if (task.isNotEmpty) {
      try {
        await _tasksCollection.add({'task': task});
        _taskController.clear();
        Get.snackbar("Success", "Task added successfully!", snackPosition: SnackPosition.BOTTOM);
      } catch (e) {
        Get.snackbar("Error", "Failed to add task", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      }
    }
  }

  // Fungsi untuk memperbarui tugas di Firestore
  Future<void> _updateTask(String docId, String newTask) async {
    try {
      await _tasksCollection.doc(docId).update({'task': newTask});
      Get.snackbar("Success", "Task updated successfully!", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Failed to update task", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // Fungsi untuk menghapus tugas dari Firestore
  Future<void> _deleteTask(String docId) async {
    try {
      await _tasksCollection.doc(docId).delete();
      Get.snackbar("Success", "Task deleted successfully!", snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar("Error", "Failed to delete task", snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }

  // Fungsi untuk logout
  void _logout() {
    // Konfirmasi sebelum logout
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Logout"),
          content: Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Get.offAll(LoginPage()); // Navigasi ke halaman login
              },
              child: Text("Logout"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("To-Do List"),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _logout, // Aksi logout pada ikon settings
          ),
        ],
      ),
      backgroundColor: Colors.blue[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Input Field dan Tambah Tugas Button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      labelText: 'Add a new task',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    _addTask(_taskController.text.trim());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Daftar Tugas dari Firestore
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _tasksCollection.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No tasks added yet!",
                        style: TextStyle(fontSize: 18, color: Colors.blueAccent),
                      ),
                    );
                  }

                  final tasks = snapshot.data!.docs;
                  return ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        color: Colors.white,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            task['task'],
                            style: TextStyle(fontSize: 18),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.blueAccent),
                                onPressed: () {
                                  _taskController.text = task['task'];
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Update Task"),
                                        content: TextField(
                                          controller: _taskController,
                                          decoration: InputDecoration(hintText: "Enter new task"),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              _updateTask(task.id, _taskController.text.trim());
                                              Navigator.of(context).pop();
                                            },
                                            child: Text("Update"),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteTask(task.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )

          ],
        ),
      ),
    );
  }
}

//Final3
