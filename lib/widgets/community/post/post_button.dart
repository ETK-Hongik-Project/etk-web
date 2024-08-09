import 'package:flutter/material.dart';

class PostPageSelectionButton extends StatelessWidget {
  const PostPageSelectionButton({
    super.key,
    required this.title,
    required this.pageWidget,
    required this.authorName,
    required this.createdTime,
  });

  final String title;
  final String authorName;
  final String createdTime;
  final Widget pageWidget;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 69,
          child: TextButton(
            style: TextButton.styleFrom(
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 11.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          authorName,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        const Text(
                          "|",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          width: 6,
                        ),
                        Text(
                          createdTime,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => pageWidget),
              );
            },
          ),
        ),
        Divider(color: Colors.deepPurple.withOpacity(0.1)), // 구분 라인 추가
      ],
    );
  }
}
