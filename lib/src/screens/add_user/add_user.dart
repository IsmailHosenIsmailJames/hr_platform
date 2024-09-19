import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hr_platform/src/models/user_model.dart';
import 'package:hr_platform/src/theme/text_field_input_decoration.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final formKey = GlobalKey<FormState>();
  TextEditingController userIDController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController userNameController = TextEditingController();
  TextEditingController cellPhoneController = TextEditingController();
  TextEditingController companyNameController = TextEditingController();
  TextEditingController dateOfJoiningController = TextEditingController();
  TextEditingController departmentNameController = TextEditingController();
  TextEditingController designationNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController jobTypeNameController = TextEditingController();

  FocusNode userIDFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode userNameFocus = FocusNode();
  FocusNode cellPhoneFocus = FocusNode();
  FocusNode companyNameFocus = FocusNode();
  FocusNode dateOfJoiningFocus = FocusNode();
  FocusNode departmentNameFocus = FocusNode();
  FocusNode designationNameFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode jobTypeNameFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Add new user"),
      ),
      body: Center(
        child: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    titleWidget("User ID", true),
                    const Gap(5),
                    TextFormField(
                      controller: userIDController,
                      focusNode: userIDFocus,
                      onFieldSubmitted: (value) {
                        passwordFocus.requestFocus();
                      },
                      validator: (value) {
                        if (value == null || value.length < 4) {
                          return "ID should be 4 digit at least";
                        } else {
                          try {
                            int.parse(value);
                            return null;
                          } catch (e) {
                            return "Not a valid digit";
                          }
                        }
                      },
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      keyboardType: TextInputType.number,
                      decoration: getInputDecooration(
                        "User ID",
                        "Type user id for new user...",
                      ),
                    ),
                    const Gap(10),
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
                      focusNode: passwordFocus,
                      onFieldSubmitted: (value) {
                        userNameFocus.requestFocus();
                      },
                      decoration: getInputDecooration(
                        "User Password",
                        "Type password for new user...",
                      ),
                    ),
                    titleWidget("User Name", false),
                    const Gap(5),
                    TextFormField(
                      controller: userNameController,
                      focusNode: userNameFocus,
                      onFieldSubmitted: (value) {
                        cellPhoneFocus.requestFocus();
                      },
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
                      focusNode: cellPhoneFocus,
                      onFieldSubmitted: (value) {
                        companyNameFocus.requestFocus();
                      },
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
                      focusNode: companyNameFocus,
                      onFieldSubmitted: (value) {
                        dateOfJoiningFocus.requestFocus();
                      },
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
                      focusNode: dateOfJoiningFocus,
                      onFieldSubmitted: (value) {
                        departmentNameFocus.requestFocus();
                      },
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
                      focusNode: departmentNameFocus,
                      onFieldSubmitted: (value) {
                        designationNameFocus.requestFocus();
                      },
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
                      focusNode: designationNameFocus,
                      onFieldSubmitted: (value) {
                        emailFocus.requestFocus();
                      },
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
                      focusNode: emailFocus,
                      onFieldSubmitted: (value) {
                        jobTypeNameFocus.requestFocus();
                      },
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
                      focusNode: jobTypeNameFocus,
                      onFieldSubmitted: (value) async {
                        await onADDButtonPressedFub(context);
                      },
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
                          await onADDButtonPressedFub(context);
                        },
                        label: const Text("ADD"),
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> onADDButtonPressedFub(BuildContext context) async {
    if (formKey.currentState!.validate()) {
      try {
        final response = await FirebaseFirestore.instance
            .collection("general_user")
            .doc(userIDController.text)
            .get();
        if (response.exists) {
          showDialog(
            // ignore: use_build_context_synchronously
            context: context,
            builder: (context) => const AlertDialog(
              title: Text("This user already exits"),
            ),
          );
        } else {
          await FirebaseFirestore.instance
              .collection("general_user")
              .doc(userIDController.text)
              .set(
                UserModel(
                  userID: userIDController.text,
                  userPassword: passwordController.text,
                  userName: userNameController.text,
                  cellPhone: cellPhoneController.text,
                  companyName: companyNameController.text,
                  dateOfJoining: dateOfJoiningController.text,
                  departmentName: departmentNameController.text,
                  designationName: designationNameController.text,
                  email: emailController.text,
                  jobTypeName: jobTypeNameController.text,
                ).toMap(),
              );
        }
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
  }
}

Widget titleWidget(String title, bool isRequired,
    {double fontsize = 20,
    MainAxisAlignment alinment = MainAxisAlignment.start}) {
  return Row(
    mainAxisAlignment: alinment,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: fontsize,
        ),
      ),
      if (isRequired) const Gap(10),
      if (isRequired)
        Text(
          "*",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: fontsize,
            color: Colors.red,
          ),
        )
    ],
  );
}
