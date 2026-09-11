import { describe, expect, it } from "vitest";
import { APP_NAME } from "../src/index";

/** 冒烟测试：验证 vitest 与 TS 编译链路。周1 起替换为真实测试。 */
describe("scaffold smoke", () => {
  it("shared 包可被导入", () => {
    expect(APP_NAME).toBe("dexpdex");
  });
});
