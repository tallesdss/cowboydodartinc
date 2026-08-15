"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserEntity = void 0;
class UserEntity {
    constructor({ id, name, email, creation_date, last_update_date, locale, welcome_sent }) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.creation_date = creation_date;
        this.last_update_date = last_update_date;
        this.locale = locale;
        this.welcome_sent = welcome_sent;
    }
    static fromData(data) {
        return new UserEntity(data);
    }
    static fromDocument(data) {
        const result = data.data();
        result.id = data.id;
        return new UserEntity(result);
    }
}
exports.UserEntity = UserEntity;
//# sourceMappingURL=user_entity.js.map