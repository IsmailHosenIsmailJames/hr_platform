import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hr_platform/src/models/user_model.dart';
import 'package:hr_platform/src/theme/text_field_input_decoration.dart';

class EditProfile extends StatefulWidget {
  final UserModel userModel;
  const EditProfile({super.key, required this.userModel});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final formKey = GlobalKey<FormState>();
  late TextEditingController passwordController;
  late TextEditingController userNameController;
  late TextEditingController cellPhoneController;
  late TextEditingController companyNameController;
  late TextEditingController dateOfJoiningController;
  late TextEditingController departmentNameController;
  late TextEditingController designationNameController;
  late TextEditingController emailController;
  late TextEditingController jobTypeNameController;
  @override
  void initState() {
    passwordController =
        TextEditingController(text: widget.userModel.userPassword);
    userNameController = TextEditingController(text: widget.userModel.userName);
    cellPhoneController =
        TextEditingController(text: widget.userModel.cellPhone);
    companyNameController =
        TextEditingController(text: widget.userModel.companyName);
    dateOfJoiningController =
        TextEditingController(text: widget.userModel.dateOfJoining);
    departmentNameController =
        TextEditingController(text: widget.userModel.departmentName);
    designationNameController =
        TextEditingController(text: widget.userModel.designationName);
    emailController = TextEditingController(text: widget.userModel.email);
    jobTypeNameController =
        TextEditingController(text: widget.userModel.jobTypeName);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit user info"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  titleWidget("User Password", true),
                  const Gap(5),
                  TextFormField(
                    validator: (value) {
                      if (value == null || value.length < 3) {
                        return "Password should be at least 4 digit";
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    controller: passwordController,
                    decoration: getInputDecooration(
                      "User Password",
                      "Type password for new user...",
                    ),
                  ),
                  titleWidget("User Name", false),
                  const Gap(5),
                  TextFormField(
                    controller: userNameController,
                    decoration: getInputDecooration(
                      "User Name",
                      "Type user name for new user...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Cell Phone", false),
                  const Gap(5),
                  TextFormField(
                    controller: cellPhoneController,
                    decoration: getInputDecooration(
                      "Cell Phone",
                      "Type user Cell Phone...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Company Name", false),
                  const Gap(5),
                  TextFormField(
                    controller: companyNameController,
                    decoration: getInputDecooration(
                      "Company Name",
                      "Type Company Name of new user...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Date Of Joining", false),
                  const Gap(5),
                  TextFormField(
                    controller: dateOfJoiningController,
                    decoration: getInputDecooration(
                      "Date Of Joining",
                      "Type Date Of Joining of new user...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Department Name", false),
                  const Gap(5),
                  TextFormField(
                    controller: departmentNameController,
                    decoration: getInputDecooration(
                      "Department Name",
                      "Type Department Name of new user...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Designation Name", false),
                  const Gap(5),
                  TextFormField(
                    controller: designationNameController,
                    decoration: getInputDecooration(
                      "Designation Name",
                      "Type Designation Name of new user...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Email", false),
                  const Gap(5),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: getInputDecooration(
                      "Email",
                      "Type Email of new user...",
                    ),
                  ),
                  const Gap(10),
                  titleWidget("Job Type Name", false),
                  const Gap(5),
                  TextFormField(
                    controller: jobTypeNameController,
                    decoration: getInputDecooration(
                      "Job Type",
                      "Type Job Type Name of new user...",
                    ),
                  ),
                  const Gap(20),
                  SizedBox(
                    width: 330,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            await FirebaseFirestore.instance
                                .collection("general_user")
                                .doc(widget.userModel.userID)
                                .update(
                                  UserModel(
                                    userID: widget.userModel.userID,
                                    userPassword: passwordController.text,
                                    userName: userNameController.text,
                                    cellPhone: cellPhoneController.text,
                                    companyName: companyNameController.text,
                                    dateOfJoining: dateOfJoiningController.text,
                                    departmentName:
                                        departmentNameController.text,
                                    designationName:
                                        designationNameController.text,
                                    email: emailController.text,
                                    jobTypeName: jobTypeNameController.text,
                                  ).toMap(),
                                );
                          } catch (e) {
                            showModalBottomSheet(
                              // ignore: use_build_context_synchronously
                              context: context,
                              builder: (context) => const Center(
                                child: Text("Somethings went worng"),
                              ),
                            );
                          }
                        }
                      },
                      label: const Text("Save Changes"),
                      icon: const Icon(Icons.done),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget titleWidget(String title, bool isRequired) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        if (isRequired) const Gap(10),
        if (isRequired)
          const Text(
            "*",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red),
          )
      ],
    );
  }
}
