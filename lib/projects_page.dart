import 'package:flutter/material.dart';
// import 'package:transparent_image/transparent_image.dart';

class ProjectPage extends StatelessWidget {
  const ProjectPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> projects = [
      {
        'name': 'Trafficking Network - Mumbai',
        'image': 'g1.png',
        'users': [
          'https://i.pravatar.cc/150?img=1',
          'https://i.pravatar.cc/150?img=2',
          'https://i.pravatar.cc/150?img=3',
        ],
        'created': '2025-01-10',
        'lastAccessed': '2025-11-05',
        'lastModified': '2025-11-04',
      },
      {
        'name': 'Financial Links - Delhi',
        'image': 'g2.png',
        'users': [
          'https://i.pravatar.cc/150?img=4',
          'https://i.pravatar.cc/150?img=5',
        ],
        'created': '2025-02-14',
        'lastAccessed': '2025-11-06',
        'lastModified': '2025-11-03',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Projects',
        ),
      ),
      body: ListView.builder(
        itemCount: projects.length,
        itemBuilder: (context, index) {
          final project = projects[index];
          final List<String> users =
              (project['users'] as List<dynamic>).cast<String>();

          return Card(
            color: const Color(0xFF2C2C2C),
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: () {
                // TODO: Navigate to project details/graph view
              },
              child: Column(
                children: [
                  // Graph snapshot
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(project["image"]),
                  ),
                  const SizedBox(width: 16),

                  // Project info
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project['name'] as String,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text(
                              'Users:',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ...users.map((u) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 4.0),
                                child: CircleAvatar(
                                  radius: 12,
                                  backgroundImage: NetworkImage(u),
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Created: ${project['created']}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          'Last Accessed: ${project['lastAccessed']}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                        Text(
                          'Last Modified: ${project['lastModified']}',
                          style:
                              const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Create new project
        },
        backgroundColor: Colors.redAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}
