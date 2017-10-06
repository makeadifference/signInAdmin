//
//  Constants.swift
//  admin
//
//  Created by drf on 2017/10/3.
//  Copyright © 2017年 drf. All rights reserved.
//

struct admin {
    // API 基址
    struct weteam {
        static let baseURL = "http://123.207.117.67/studentsignin/admin/"
    }
    
    struct Method {
        // 获取当前时间
        static let currTime = "http://123.207.117.67/studentsignin/getCurrTime"
        // 获取验证码
        static let getVCode = "http://123.207.117.67/studentsignin/getVCode?vName=adminVCode"
        static let login = "http://123.207.117.67/studentsignin/admin/login"
        // 学生模块
        static let addStudent = "student/add"
        static let deleteStudent = "student/delete"
        static let getStuCount = "student/count"
        static let searchStudent = "student/search"
        static let getAllStu = "student/getAll"
        static let updateStu = "student/update"
        // 教室模块
        static let addClassRoom = "classroom/add"
        static let updateClassRoom = "classroom/update"
        static let deleteClassRoom = "classroom/delete"
        static let searchClassRoom = "classroom/search"
        static let getAllClassRoom = "classroom/getAll"
        static let getClassLayout = "classroom/getClassroomJsonLayout" // 有误
        // 课程模块
        static let addCourse = "course/add"
        static let updateCourse = "course/update"
        static let deleteCourse = "course/delete"
        static let getCourseCount = "course/count"
        static let searchCourse = "course/search"
        static let getAllCourse = "course/getAll"
        static let getCoursebyID = "course/get"
        // 课程表模块
        static let setClassSchedule = "studentClassSchedule/set"
        static let getClassSchedule = "studentClassSchedule/get"
        // 签到模块
        static let signRecordByStudent = "signRecord/getByStudent"
        static let signRecordByCourse = "signRecord/getByCourse"
        
        
    }
    
}

