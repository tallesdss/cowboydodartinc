"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserDeviceAdapter = exports.UserDeviceEntity = exports.UserDevice = void 0;
const entity_utils_1 = require("./entity_utils");
exports.UserDevice = {
    ANDROID: "android",
    IOS: "ios",
    WEB: "WEB",
};
class UserDeviceEntity {
    constructor({ id, token, device_id, type, operatingSystem, creation_date, extra_data, }) {
        this.id = id;
        this.token = token;
        this.device_id = device_id;
        this.type = type;
        this.operatingSystem = operatingSystem;
        this.creation_date = creation_date;
        this.extra_data = extra_data;
    }
    static fromData(data) {
        return new UserDeviceEntity(data);
    }
    static fromDocument(data) {
        const resData = data.data();
        resData.id = data.id;
        return new UserDeviceEntity(resData);
    }
}
exports.UserDeviceEntity = UserDeviceEntity;
class UserDeviceAdapter {
    static toMap(data) {
        const cleanData = (0, entity_utils_1.cleanEntityId)(data);
        return Object.assign({}, cleanData);
    }
}
exports.UserDeviceAdapter = UserDeviceAdapter;
//# sourceMappingURL=user_device_entity.js.map