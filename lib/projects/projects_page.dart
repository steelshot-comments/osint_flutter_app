import 'package:knotwork/components/squircle_button.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProjectPage extends StatefulWidget {
  const ProjectPage({super.key});

  @override
  State<ProjectPage> createState() => _ProjectPageState();
}

class _ProjectPageState extends State<ProjectPage> {
  final auth_api_url = dotenv.env['AUTH_API_URL'];
  final Dio _dio = Dio();

  List<Map<String, dynamic>> projects = [];
  bool isLoading = true;
  String? errorMessage;

  // Fetch all projects for a given user
  Future<void> _fetchProjects() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await _dio.get(
        '$auth_api_url/projects/',
        data: {"userID": 4},
      );

      debugPrint("🟢 Raw response: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;

        // FastAPI wraps JSON as {success, message, data}
        final List<dynamic> projectsData = data['projects'] ?? [];

        setState(() {
          projects = List<Map<String, dynamic>>.from(projectsData);
          isLoading = false;
        });
      } else {
        throw Exception("Server error: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to load projects. Please try again.";
      });
    }
  }

  // Create a new project via POST
  Future<void> _createProject(String name, String description) async {
    try {
      final response = await _dio.post(
        '$auth_api_url/projects/add',
        data: {
          "userID": 4,
          "username": "Yeshaya",
          "name": name,
          "description": description,
          "visibility": "private",
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Project created successfully")),
        );
        await _fetchProjects(); // reload list
      } else {
        throw Exception("Failed to create project");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error creating project")),
      );
    }
  }

  // Show dialog for new project
  Future<void> _showCreateProjectDialog() async {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create Project"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Project Name"),
            ),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Description"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final desc = descriptionController.text.trim();

              if (name.isNotEmpty) {
                Navigator.pop(context);
                _createProject(name, desc);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteProject(int projectID)async{
    try{
      final response = await _dio.post('$auth_api_url/projects/delete', data: {'projectID': projectID});
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Project deleted successfully")),
        );
        await _fetchProjects();
      } else {
        throw Exception("Failed to delete project");
      }
    }
    catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not delete project")),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('My Projects'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(child: Text(errorMessage!))
              : projects.isEmpty
                  ? const Center(
                      child: Text(
                        "No projects yet. Tap + to create one.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      itemCount: projects.length,
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 400, // max width for each card
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio:
                            3 / 2, // tweak to fit your card height
                      ),
                      itemBuilder: (context, index) {
                        final project = projects[index];

                        return Card(
                          color: theme.colorScheme.secondaryContainer,
                          child: InkWell(
                            onTap: () {
                              Navigator.of(context).pushNamed('/investigation');
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    project['name'] ?? 'Untitled Project',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      // color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    project['description'] ?? 'No description',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Created: ${project['created_at'] ?? 'N/A'}',
                                    style: TextStyle(
                                        color: theme.colorScheme.secondary, fontSize: 12),
                                  ),
                                  const Spacer(),
                                  Row(
                                    spacing: 8.0,
                                    children: [
                                      SquircleButton(
                                        onTap: () {},
                                        title: 'Edit',
                                        background: Colors.yellow[200],
                                        icon: Icons.edit,
                                      ),
                                      SquircleButton(
                                        onTap: () => _deleteProject(project['id']),
                                        title: 'Delete',
                                        background: Colors.red[200],
                                        icon: Icons.delete,
                                      )
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateProjectDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
